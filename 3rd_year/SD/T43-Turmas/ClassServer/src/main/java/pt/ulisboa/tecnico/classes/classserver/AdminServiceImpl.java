package pt.ulisboa.tecnico.classes.classserver;

import pt.ulisboa.tecnico.classes.contract.admin.AdminServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.admin.AdminClassServer.*;
import pt.ulisboa.tecnico.classes.classserver.frontend.ClassServerFrontend;
import pt.ulisboa.tecnico.classes.classserver.domain.Turma;
import pt.ulisboa.tecnico.classes.contract.ClassesDefinitions.*;

import io.grpc.stub.StreamObserver;

import java.util.concurrent.ConcurrentHashMap;
import java.util.ArrayList;
import java.util.logging.Logger;

public class AdminServiceImpl extends AdminServiceGrpc.AdminServiceImplBase{
    private Turma turma;
    private boolean isDebugActive;
    private static final Logger log = Logger.getLogger(AdminServiceImpl.class.getName());

    //constructor
    public AdminServiceImpl(Turma newClass, boolean debugFlag){
        turma = newClass;
        isDebugActive = debugFlag;
    }

    @Override
    public void activate(ActivateRequest request, StreamObserver<ActivateResponse> responseObserver) {
        boolean isServerActive = turma.getIsServerActive();
        if (isServerActive == false){
            turma.setIsServerActive(true);
        }
        ActivateResponse response = ActivateResponse.newBuilder().setCode(ResponseCode.OK).build();
        responseObserver.onNext(response);
        responseObserver.onCompleted();
        printDebugMessage(log, 1, isDebugActive);
    }

    @Override
    public void deactivate(DeactivateRequest request, StreamObserver<DeactivateResponse> responseObserver) {
        turma.setIsServerActive(false);

        DeactivateResponse response = DeactivateResponse.newBuilder().setCode(ResponseCode.OK).build();
        responseObserver.onNext(response);
        responseObserver.onCompleted();  
        printDebugMessage(log, 2, isDebugActive);  
    }

    @Override
    public void dump(DumpRequest request, StreamObserver<DumpResponse> responseObserver) {
        ConcurrentHashMap<String, String> enrolledList = turma.getEnrolledList();
        ConcurrentHashMap<String, String> discardedList = turma.getDiscardedList();
        ArrayList<Student> enr = new ArrayList<>();
        ArrayList<Student> disc = new ArrayList<>();
        
        if(!enrolledList.isEmpty()){
            enrolledList.forEach((k, v) -> enr.add(Student.newBuilder().setStudentId(k).setStudentName(v).build()));
        }
        if(!discardedList.isEmpty()){
            discardedList.forEach((k, v) -> disc.add(Student.newBuilder().setStudentId(k).setStudentName(v).build()));
        }
        ClassState state = ClassState.newBuilder().setCapacity(turma.getCapacity()).setOpenEnrollments(turma.getOpenEnrollments()).addAllEnrolled(enr).addAllDiscarded(disc).build();
        DumpResponse response = DumpResponse.newBuilder().setCode(ResponseCode.OK).setClassState(state).build();
        responseObserver.onNext(response);
        responseObserver.onCompleted();
        printDebugMessage(log, 3, isDebugActive);
    }

    @Override
    public synchronized void deactivateGossip(DeactivateGossipRequest request, StreamObserver<DeactivateGossipResponse> responseObserver) {       
        if (turma.getIsServerActive() == false) {
            DeactivateGossipResponse response = DeactivateGossipResponse.newBuilder().setCode(ResponseCode.INACTIVE_SERVER).build();
            responseObserver.onNext(response);
            responseObserver.onCompleted();  
            printDebugMessage(log, 7, isDebugActive); 
        } else {
            turma.setIsGossipActive(false);
            DeactivateGossipResponse response = DeactivateGossipResponse.newBuilder().setCode(ResponseCode.OK).build();
            responseObserver.onNext(response);
            responseObserver.onCompleted();  
            printDebugMessage(log, 4, isDebugActive);  
        }
    }

    @Override
    public synchronized void activateGossip(ActivateGossipRequest request, StreamObserver<ActivateGossipResponse> responseObserver) {
        if (turma.getIsServerActive() == false) {
            ActivateGossipResponse response = ActivateGossipResponse.newBuilder().setCode(ResponseCode.INACTIVE_SERVER).build();
            responseObserver.onNext(response);
            responseObserver.onCompleted();  
            printDebugMessage(log, 7, isDebugActive); 
        } else {
            turma.setIsGossipActive(true);
            ActivateGossipResponse response = ActivateGossipResponse.newBuilder().setCode(ResponseCode.OK).build();
            responseObserver.onNext(response);
            responseObserver.onCompleted();  
            printDebugMessage(log, 5, isDebugActive);  
        }
    }

    @Override
    public synchronized void gossip(GossipRequest request, StreamObserver<GossipResponse> responseObserver) {
        ClassServerFrontend classServerFrontend = new ClassServerFrontend();
        boolean isGossipActive = turma.getIsGossipActive();
        if (turma.getIsServerActive() == false) {
            GossipResponse response = GossipResponse.newBuilder().setCode(ResponseCode.INACTIVE_SERVER).build();
            responseObserver.onNext(response);
            responseObserver.onCompleted();  
            printDebugMessage(log, 7, isDebugActive); 
        } else if (turma.getIsServerActive() == true && isGossipActive == true) {
            String qualifier = request.getQualifier();
            classServerFrontend.propagateState(turma, qualifier);

            GossipResponse response = GossipResponse.newBuilder().setCode(ResponseCode.OK).build();
            responseObserver.onNext(response);
            responseObserver.onCompleted();  
            printDebugMessage(log, 6, isDebugActive); 
        } else {
            printDebugMessage(log, 8, isDebugActive); 
        }
    }

    public void printDebugMessage(Logger log, Integer messageCode, boolean isDebugActive){
        if (isDebugActive == true){
            if(messageCode == 1)
                log.info("Admin activated server.");         
            else if(messageCode == 2)
                log.info("Admin deactivated server.");        
            else if(messageCode == 3)
                log.info("Admin dumped server.");    
            else if(messageCode == 4)
                log.info("Admin deactivated gossip.");     
            else if(messageCode == 5)
                log.info("Admin activated gossip.");      
            else if(messageCode == 6)
                log.info("Admin used gossip");            
            else if(messageCode == 7)
                log.info("Server is inactive.");      
            else if(messageCode == 8)
                log.info("Server is unable to propagate. Gossip is deactivated.");                                          
        }    
    }
}
