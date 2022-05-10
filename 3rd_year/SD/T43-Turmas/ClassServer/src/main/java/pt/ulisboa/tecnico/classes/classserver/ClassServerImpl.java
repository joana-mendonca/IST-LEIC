package pt.ulisboa.tecnico.classes.classserver;

import io.grpc.stub.StreamObserver;

import pt.ulisboa.tecnico.classes.contract.classserver.ClassServerServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.classserver.ClassServerClassServer.*;
import pt.ulisboa.tecnico.classes.classserver.domain.Turma;
import pt.ulisboa.tecnico.classes.contract.ClassesDefinitions.*;

import java.util.Collections;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;

import java.util.logging.Logger;

public class ClassServerImpl extends ClassServerServiceGrpc.ClassServerServiceImplBase {
    private Turma turma;
    private boolean isDebugActive;
    boolean isGossipActive;
    Logger log = Logger.getLogger(ProfessorServiceImpl.class.getName());
    
    public ClassServerImpl(Turma newClass, boolean debugFlag){
        turma = newClass;
        isDebugActive = debugFlag;
    }

    @Override
    public void propagateState(PropagateStateRequest request, StreamObserver<PropagateStateResponse> responseObserver){
        ClassState classState = request.getClassState();
        String qualifier = request.getQualifier();
        isGossipActive =  turma.getIsGossipActive();

        if (turma.getIsServerActive() == false) {
            PropagateStateResponse response = PropagateStateResponse.newBuilder().setCode(ResponseCode.INACTIVE_SERVER).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 1, isDebugActive);         
        } else if (turma.getIsServerActive() == true && isGossipActive == true){
            propagate(classState, qualifier, isGossipActive);
            
            PropagateStateResponse response = PropagateStateResponse.newBuilder().setCode(ResponseCode.OK).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 2, isDebugActive); 
        } else {
            System.out.println("Gossip is deactivated");
        }
    }

    public void propagate(ClassState classState, String qualifier, boolean isGossipActive){
        Integer capacity = classState.getCapacity();
        
        if (qualifier.equals("P")){
            turma.setCapacity(capacity);
            turma.setOpenEnrollments(classState.getOpenEnrollments());
        }
        
        //Update Enrolled List
        List<Student> propagatedEnrolledList = classState.getEnrolledList();
        if (propagatedEnrolledList.size() > 0){
            for(int i = 0; i < propagatedEnrolledList.size(); i++){
                String studentId = propagatedEnrolledList.get(i).getStudentId();
                String studentName = propagatedEnrolledList.get(i).getStudentName();
                turma.enroll(studentId, studentName);
            }
        }

        //Update Discarded List
        List<Student> propagatedDiscardedList = classState.getDiscardedList();
        if(propagatedDiscardedList.size() > 0){
            for(int i = 0; i < propagatedDiscardedList.size(); i++){
                String studentId = propagatedDiscardedList.get(i).getStudentId();
                String studentName = propagatedDiscardedList.get(i).getStudentName();
                turma.discard(studentId, studentName);
            }
        }

        //Check incoherence
        if (turma.getEnrolledList().size() > turma.getCapacity()){ 
            fixIncoherence(turma, turma.getCapacity());     
        }

        //Removes student from enrolled list if it is in discarded list
        ConcurrentHashMap<String, String> discardedList = turma.getDiscardedList();
        for (Map.Entry<String, String> entry : discardedList.entrySet()) {
            String studentId = entry.getKey();
            if (turma.getEnrolledList().containsKey(studentId))
                turma.removeEnrolledListEntry(studentId);
        }
    }

    public static void fixIncoherence(Turma turma, Integer capacity){
        ConcurrentHashMap<String, String> enrolledList = turma.getEnrolledList();
        ArrayList<String> sortedKeys = new ArrayList<String>(turma.getEnrolledList().keySet());
        int counter = 0;

        //Sorts enrolled list by studentId
        Collections.sort(sortedKeys);

        for (String key : sortedKeys) {
            String value = enrolledList.get(key);

            if (counter < capacity){
                turma.enroll(key, value);
                counter++;
            } else {
                turma.discard(key, value);
            }
            
        }
    }

    public void printDebugMessage(Logger log, Integer messageCode, boolean isDebugActive){
        if (isDebugActive == true){
            if(messageCode == 1)
                log.info("Server is down."); 
            if(messageCode == 2)
                log.info("Server propagates state.");           
        }
    }
}
