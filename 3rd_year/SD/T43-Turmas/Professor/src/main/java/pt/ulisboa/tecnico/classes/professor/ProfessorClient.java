package pt.ulisboa.tecnico.classes.professor;

import java.io.IOException;
import java.util.Scanner;

import io.grpc.StatusRuntimeException;
import pt.ulisboa.tecnico.classes.namingserver.frontend.NamingServerFrontend;
import pt.ulisboa.tecnico.classes.contract.ClassesDefinitions.ResponseCode;
import pt.ulisboa.tecnico.classes.contract.professor.ProfessorServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.professor.ProfessorClassServer.*;
import pt.ulisboa.tecnico.classes.Stringify;

import java.util.List;
import java.util.ArrayList;

public class ProfessorClient {
  private static final String service = "turmas";
  private static final String EXIT = "exit";
  private static final String OPEN_ENROLLMENTS = "openEnrollments";
  private static final String CLOSE_ENROLLMENTS = "closeEnrollments";
  private static final String LIST = "list";
  private static final String CANCEL_ENROLLMENT = "cancelEnrollment";
  public static void main(String[] args) throws IOException, InterruptedException {
    NamingServerFrontend namingServerFrontend = new NamingServerFrontend();
		
    Scanner scanner = new Scanner(System.in);
    
		while (true) {
			System.out.printf("> ");
      try{
        String line = scanner.nextLine();
        String[] input = line.split(" ");
        //Exit
        if (EXIT.equals(line)) {
          scanner.close();
          System.exit(0);
        }
        //Primary/Secondary server operations
        else if (LIST.equals(line) || CANCEL_ENROLLMENT.equals(input[0])){
          List<String> qualifiers = new ArrayList<String>();
          qualifiers.add("P");
          qualifiers.add("S");
          final ProfessorServiceGrpc.ProfessorServiceBlockingStub professorStub = namingServerFrontend.professorConnectsToServer(service, qualifiers);

          if (professorStub != null && LIST.equals(line)){
            ListClassResponse listResponse = professorStub.listClass(ListClassRequest.getDefaultInstance()); 
            if (listResponse.getCode().equals(ResponseCode.OK)) 
              System.out.println(Stringify.format(listResponse.getClassState()) + "\n");
            else{
              System.out.println(Stringify.format(listResponse.getCode()) + "\n");  
            }
          } 
          else if(professorStub != null && CANCEL_ENROLLMENT.equals(input[0])) {         
            String studentId = String.valueOf(input[1]);
            CancelEnrollmentResponse response = professorStub.cancelEnrollment(CancelEnrollmentRequest.newBuilder().setStudentId(studentId).build());
            System.out.println(Stringify.format(response.getCode()) + "\n");
          }
          else{
            System.out.println("No servers available");
          }
        } 
        //Primary server operations
        else {
          List<String> qualifiers = new ArrayList<String>();
          qualifiers.add("P");
          final ProfessorServiceGrpc.ProfessorServiceBlockingStub professorStub = namingServerFrontend.professorConnectsToServer(service, qualifiers);

          
          if(professorStub != null){
            if (OPEN_ENROLLMENTS.equals(input[0])) {		        
              Integer capacity = Integer.valueOf(input[1]); 
              OpenEnrollmentsResponse response = professorStub.openEnrollments(OpenEnrollmentsRequest.newBuilder().setCapacity(capacity).build());
              System.out.println(Stringify.format(response.getCode()) + "\n");        
            }
    
            else if (CLOSE_ENROLLMENTS.equals(input[0])) {				
              CloseEnrollmentsResponse response = professorStub.closeEnrollments(CloseEnrollmentsRequest.newBuilder().build());
              System.out.println(Stringify.format(response.getCode()) + "\n");
            }
          } else {
            System.out.println(ResponseCode.WRITING_NOT_SUPPORTED);
          }
        }
      } catch (StatusRuntimeException e) {
        System.out.println("Caught exception with description: " + e.getStatus().getDescription());
      }
		}
  }
}
