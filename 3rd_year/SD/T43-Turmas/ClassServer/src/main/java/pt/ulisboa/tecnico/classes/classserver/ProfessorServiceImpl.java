package pt.ulisboa.tecnico.classes.classserver;

import pt.ulisboa.tecnico.classes.contract.professor.ProfessorServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.professor.ProfessorServiceGrpc.ProfessorServiceImplBase;
import pt.ulisboa.tecnico.classes.contract.professor.ProfessorClassServer.*;
import pt.ulisboa.tecnico.classes.classserver.domain.Turma;
import pt.ulisboa.tecnico.classes.contract.ClassesDefinitions.*;

import java.util.List;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

import io.grpc.stub.StreamObserver;

// gRPC Professor service implementation relying on domain object Turma 
public class ProfessorServiceImpl extends ProfessorServiceGrpc.ProfessorServiceImplBase{
    private Turma turma;
    private boolean isDebugActive;
    Logger log = Logger.getLogger(ProfessorServiceImpl.class.getName());
    
    //constructor
    public ProfessorServiceImpl(Turma newClass, boolean flag){
        turma = newClass;
        isDebugActive = flag;
    }
     
    @Override
    public synchronized void openEnrollments(OpenEnrollmentsRequest request, StreamObserver<OpenEnrollmentsResponse> responseObserver) {
        Integer capacity = request.getCapacity();
        boolean openEnrollments = turma.getOpenEnrollments();
        Integer numberOfStudentEnrolled = turma.getNumberOfStudentsEnrolled();
        
        if (turma.getIsServerActive() == false){
            OpenEnrollmentsResponse response = OpenEnrollmentsResponse.newBuilder().setCode(ResponseCode.INACTIVE_SERVER).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 1, isDebugActive);        
        }
        else if (openEnrollments == false && capacity <= numberOfStudentEnrolled) {
            OpenEnrollmentsResponse response = OpenEnrollmentsResponse.newBuilder().setCode(ResponseCode.FULL_CLASS).build();
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 2, isDebugActive);  
        } 
        else if (openEnrollments == true){
            OpenEnrollmentsResponse response = OpenEnrollmentsResponse.newBuilder().setCode(ResponseCode.ENROLLMENTS_ALREADY_OPENED).build();
            responseObserver.onNext(response);
            responseObserver.onCompleted(); 
            printDebugMessage(log, 3, isDebugActive);  
        } else {
            turma.setCapacity(capacity);
            turma.setOpenEnrollments(true);
            
            OpenEnrollmentsResponse response = OpenEnrollmentsResponse.newBuilder().setCode(ResponseCode.OK).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 4, isDebugActive);  
        }
    }

    @Override
    public synchronized void closeEnrollments(CloseEnrollmentsRequest request, StreamObserver<CloseEnrollmentsResponse> responseObserver) {  
        boolean openEnrollments = turma.getOpenEnrollments();

        if (turma.getIsServerActive() == false){
            CloseEnrollmentsResponse response = CloseEnrollmentsResponse.newBuilder().setCode(ResponseCode.INACTIVE_SERVER).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted(); 
            printDebugMessage(log, 5, isDebugActive);       
        }
        else if (openEnrollments == false){
            CloseEnrollmentsResponse response = CloseEnrollmentsResponse.newBuilder().setCode(ResponseCode.ENROLLMENTS_ALREADY_CLOSED).build(); 

            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 6, isDebugActive);
        } else {
            turma.setOpenEnrollments(false);           
            CloseEnrollmentsResponse response = CloseEnrollmentsResponse.newBuilder().setCode(ResponseCode.OK).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 7, isDebugActive); 
        }
    }
    
    @Override
    public synchronized void listClass(ListClassRequest request, StreamObserver<ListClassResponse> responseObserver) {  
        Integer capacity = turma.getCapacity(); 
        boolean openEnrollments = turma.getOpenEnrollments();
        ConcurrentHashMap<String, String> enrolledList = turma.getEnrolledList();
        ConcurrentHashMap<String, String> discardedList = turma.getDiscardedList();
        
        if (turma.getIsServerActive() == false){
            ListClassResponse response = ListClassResponse.newBuilder().setCode(ResponseCode.INACTIVE_SERVER).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted();   
            printDebugMessage(log, 8, isDebugActive);      
        } else {
            List<Student> enrolled = new ArrayList<Student>();
            enrolledList.forEach((key, value) -> enrolled.add(Student.newBuilder().setStudentId(key).setStudentName(value).build()));
            List<Student> discarded = new ArrayList<Student>();
            discardedList.forEach((key, value) -> discarded.add(Student.newBuilder().setStudentId(key).setStudentName(value).build()));
        
            ClassState classState =  ClassState.newBuilder().setCapacity(capacity).setOpenEnrollments(openEnrollments).addAllEnrolled(enrolled).addAllDiscarded(discarded).build();
            
            ListClassResponse response = ListClassResponse.newBuilder().setCode(ResponseCode.OK).setClassState(classState).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted(); 
            printDebugMessage(log, 9, isDebugActive); 
        }
    }

    @Override
    public synchronized void cancelEnrollment(CancelEnrollmentRequest request, StreamObserver<CancelEnrollmentResponse> responseObserver) {  
        String studentId = request.getStudentId();
        boolean isStudentEnrolled = turma.isStudentEnrolled(studentId);
        
        if (turma.getIsServerActive() == false){
            CancelEnrollmentResponse response = CancelEnrollmentResponse.newBuilder().setCode(ResponseCode.INACTIVE_SERVER).build(); 
            responseObserver.onNext(response);
            responseObserver.onCompleted();  
            printDebugMessage(log, 10, isDebugActive);      
        }
        else if (isStudentEnrolled == false){
            CancelEnrollmentResponse response = CancelEnrollmentResponse.newBuilder().setCode(ResponseCode.NON_EXISTING_STUDENT).build();    
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 11, isDebugActive);
        } else {
            turma.cancelEnrollment(studentId);
            CancelEnrollmentResponse response = CancelEnrollmentResponse.newBuilder().setCode(ResponseCode.OK).build();    
            responseObserver.onNext(response);
            responseObserver.onCompleted();
            printDebugMessage(log, 12, isDebugActive);
        }        
    }

    public void printDebugMessage(Logger log, Integer messageCode, boolean isDebugActive){
        if (isDebugActive == true){
            if(messageCode == 1)
                log.info("Professor is unable to open enrollments. Server is inactive.");         
            else if(messageCode == 2)
                log.info("Professor is unable to open enrollments. Class is full.");        
            else if(messageCode == 3)
                log.info("Professor is unable to open enrollments. Enrollments are already open.");
            else if(messageCode == 4)
                log.info("Professor opens enrollments.");  
            else if(messageCode == 5)
                log.info("Professor is unable to close enrollments. Server is inactive."); 
            else if(messageCode == 6)
                log.info("Professor is unable to close enrollments. Enrollments are already closed.");
            else if(messageCode == 7)
                log.info("Professor closes enrollments.");     
            else if(messageCode == 8)
                log.info("Professor is unable to list class. Server is inactive.");      
            else if(messageCode == 9)
                log.info("Professor lists class.");  
            else if(messageCode == 10)
                log.info("Professor is unable to cancel student's enrollment. Server is inactive.");  
            else if(messageCode == 11)
                log.info("Professor is unable to cancel student's enrollment. Student does not exist."); 
            else if(messageCode == 12)
                log.info("Professor cancelled student enrollment.");                    
        }    
    }
}