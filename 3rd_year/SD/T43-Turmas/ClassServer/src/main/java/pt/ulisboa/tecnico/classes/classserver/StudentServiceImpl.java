package pt.ulisboa.tecnico.classes.classserver;

import pt.ulisboa.tecnico.classes.contract.student.StudentServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.student.StudentClassServer.*;
import pt.ulisboa.tecnico.classes.classserver.domain.Turma;
import pt.ulisboa.tecnico.classes.contract.ClassesDefinitions.*;

import java.util.List;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

import io.grpc.stub.StreamObserver;

// gRPC Student service implementation relying on domain object Turma 
public class StudentServiceImpl extends StudentServiceGrpc.StudentServiceImplBase {
    private Turma turma;
    private boolean isDebugActive;
    Logger log = Logger.getLogger(StudentServiceImpl.class.getName());
    
    //constructor
    public StudentServiceImpl(Turma newClass, boolean flag){
        turma = newClass;
        isDebugActive = flag;
    }
    
    @Override
    public void listClass(ListClassRequest request, StreamObserver<ListClassResponse> responseObserver) {
        Integer capacity = turma.getCapacity(); 
        boolean openEnrollments = turma.getOpenEnrollments();
        ConcurrentHashMap<String, String> enrolledList = turma.getEnrolledList();
        ConcurrentHashMap<String, String> discardedList = turma.getDiscardedList();

        if (turma.getIsServerActive() == false){
            ListClassResponse response = ListClassResponse.newBuilder().setCode(ResponseCode.INACTIVE_SERVER).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 1, isDebugActive);         
        } else {
            List<Student> enrolled = new ArrayList<Student>();
            enrolledList.forEach((key, value) -> enrolled.add(Student.newBuilder().setStudentId(key).setStudentName(value).build()));
            List<Student> discarded = new ArrayList<Student>();
            discardedList.forEach((key, value) -> discarded.add(Student.newBuilder().setStudentId(key).setStudentName(value).build()));
           
            ClassState classState =  ClassState.newBuilder().setCapacity(capacity).setOpenEnrollments(openEnrollments).addAllEnrolled(enrolled).addAllDiscarded(discarded).build();
            
            ListClassResponse response = ListClassResponse.newBuilder().setCode(ResponseCode.OK).setClassState(classState).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 2, isDebugActive); 
        }                  
    }

    @Override
    public void enroll(EnrollRequest request, StreamObserver<EnrollResponse> responseObserver){
        String studentId = request.getStudent().getStudentId(); 
        String studentName = request.getStudent().getStudentName(); 
        boolean openEnrollments = turma.getOpenEnrollments();
        boolean isStudentDiscarded = turma.isStudentDiscarded(studentId);
        Integer classCapacity = turma.getCapacity();
        Integer numberOfStudentsEnrolled = turma.getNumberOfStudentsEnrolled();
        
        if (turma.getIsServerActive() == false){
            EnrollResponse response = EnrollResponse.newBuilder().setCode(ResponseCode.INACTIVE_SERVER).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted(); 
            printDebugMessage(log, 3, isDebugActive);        
        }        
        else if (openEnrollments == true){
            if (numberOfStudentsEnrolled == classCapacity){
                EnrollResponse response = EnrollResponse.newBuilder().setCode(ResponseCode.FULL_CLASS).build(); 
                responseObserver.onNext(response);
                responseObserver.onCompleted();        
                printDebugMessage(log, 4, isDebugActive); 
            } 
            else if (isStudentDiscarded == true){
                turma.removeStudentDiscardedList(studentId, studentName);
                turma.enroll(studentId, studentName);
                
                EnrollResponse response = EnrollResponse.newBuilder().setCode(ResponseCode.OK).build(); 
                responseObserver.onNext(response);
                responseObserver.onCompleted();
                printDebugMessage(log, 5, isDebugActive); 
            } else{
                turma.enroll(studentId, studentName);
                EnrollResponse response = EnrollResponse.newBuilder().setCode(ResponseCode.OK).build(); 
                responseObserver.onNext(response);
                responseObserver.onCompleted();   
                printDebugMessage(log, 5, isDebugActive);  
            }
        } else {
            EnrollResponse response = EnrollResponse.newBuilder().setCode(ResponseCode.ENROLLMENTS_ALREADY_CLOSED).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 6, isDebugActive); 
        }
    }
    public void printDebugMessage(Logger log, Integer messageCode, boolean isDebugActive){
        if (isDebugActive == true){
            if(messageCode == 1)
                log.info("Student is unable to list class. Server is inactive.");         
            else if(messageCode == 2)
                log.info("Student lists class.");      
            else if(messageCode == 3)
                log.info("Student is unable to enroll. Server is inactive");    
            else if(messageCode == 4)
                log.info("Student is unable to enroll. Class is full.");
            else if(messageCode == 5)
                log.info("Student is enrolled in class.");  
            else if(messageCode == 6)
                log.info("Student is unable to enroll. Enrollments are already closed."); 
    
        }
    }
}
