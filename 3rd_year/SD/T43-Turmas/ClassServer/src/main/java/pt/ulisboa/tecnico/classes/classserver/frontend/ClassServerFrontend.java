package pt.ulisboa.tecnico.classes.classserver.frontend;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

import io.grpc.StatusRuntimeException;
import pt.ulisboa.tecnico.classes.Stringify;
import pt.ulisboa.tecnico.classes.classserver.domain.Turma;
import pt.ulisboa.tecnico.classes.contract.ClassesDefinitions.ClassState;
import pt.ulisboa.tecnico.classes.contract.ClassesDefinitions.Student;
import pt.ulisboa.tecnico.classes.contract.classserver.ClassServerClassServer.*;
import pt.ulisboa.tecnico.classes.contract.classserver.ClassServerServiceGrpc;
import pt.ulisboa.tecnico.classes.namingserver.frontend.NamingServerFrontend;

public class ClassServerFrontend {
  NamingServerFrontend namingServerFrontend = new NamingServerFrontend();
  private static final String service = "turmas";
 
  public ClassServerFrontend(){}

  public void propagateState(Turma turma, String qualifier){

    try{
      Integer capacity = turma.getCapacity(); 
      boolean openEnrollments = turma.getOpenEnrollments();
      ConcurrentHashMap<String, String> enrolledList = turma.getEnrolledList();
      ConcurrentHashMap<String, String> discardedList = turma.getDiscardedList();
      
      List<Student> enrolled = new ArrayList<Student>();
      enrolledList.forEach((key, value) -> enrolled.add(Student.newBuilder().setStudentId(key).setStudentName(value).build()));
      
      List<Student> discarded = new ArrayList<Student>();
      discardedList.forEach((key, value) -> discarded.add(Student.newBuilder().setStudentId(key).setStudentName(value).build()));
  
      ClassState classState =  ClassState.newBuilder().setCapacity(capacity).setOpenEnrollments(openEnrollments).addAllEnrolled(enrolled).addAllDiscarded(discarded).build();

      final ClassServerServiceGrpc.ClassServerServiceBlockingStub classServerStub = namingServerFrontend.classServerConnectsToServer(service, qualifier);
      if (classServerStub != null){
        PropagateStateResponse response = classServerStub.propagateState(PropagateStateRequest.newBuilder().setClassState(classState).setQualifier(qualifier).build());
        System.out.println(Stringify.format(response.getCode()) + "\n");	 
      } else {
        System.out.println("Server is waiting for connection...");
      }
      
    } catch (StatusRuntimeException e) {
      System.out.println("Caught exception with description: " + e.getStatus().getDescription());
    }
  }
}