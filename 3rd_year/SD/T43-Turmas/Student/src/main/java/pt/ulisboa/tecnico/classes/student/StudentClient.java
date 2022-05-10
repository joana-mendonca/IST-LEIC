package pt.ulisboa.tecnico.classes.student;

import java.util.Scanner;

import java.io.IOException;

import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.StatusRuntimeException;

import pt.ulisboa.tecnico.classes.namingserver.frontend.NamingServerFrontend;
import pt.ulisboa.tecnico.classes.contract.naming.ClassServerNamingServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.naming.ClassServerNamingServer.*;
import pt.ulisboa.tecnico.classes.contract.student.StudentServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.student.StudentClassServer.*;
import pt.ulisboa.tecnico.classes.contract.ClassesDefinitions.*;
import pt.ulisboa.tecnico.classes.Stringify;

import java.util.List;
import java.util.ArrayList;
import java.util.Random;

public class StudentClient {
  private static final String service = "turmas";
  private static final String EXIT = "exit";
  private static final String LIST = "list";
  private static final String ENROLL = "enroll";

  public static void main(String[] args) throws IOException, InterruptedException {
    NamingServerFrontend namingServerFrontend = new NamingServerFrontend();
    
    //Verify input
    String studentId = args[0];  
    String studentName = concatStudentName(args);
    boolean isInputCorrect = verifyInput(studentId, studentName); 
    if (isInputCorrect == false){
      System.out.println("Incorrect student credentials");
      System.exit(0);
    }

    Scanner scanner = new Scanner(System.in);

		while (true) {
			System.out.printf("> ");
      try{
        String line = scanner.nextLine();
        String[] input = line.split(" ");

        List<String> qualifiers = new ArrayList<String>();
        qualifiers.add("P");
        qualifiers.add("S");
        final StudentServiceGrpc.StudentServiceBlockingStub studentStub = namingServerFrontend.studentConnectsToServer(service, qualifiers); 
        
        if (LIST.equals(line)) {
          if (studentStub != null){
            ListClassResponse response = studentStub.listClass(ListClassRequest.getDefaultInstance());            
            if (response.getCode().equals(ResponseCode.OK)) 
              System.out.println(Stringify.format(response.getClassState()) + "\n");
            else
              System.out.println(Stringify.format(response.getCode()) + "\n");  
          } else{
            System.out.println("No servers available");
          }
        }     
        else if (ENROLL.equals(input[0])) {	 
          if (studentStub != null){
            if (isInputCorrect == true){
              EnrollResponse response = studentStub.enroll(EnrollRequest.newBuilder().setStudent(Student.newBuilder().setStudentId(studentId).setStudentName(studentName).build()).build());
              System.out.println(Stringify.format(response.getCode()) + "\n");
            } 
          } 
        }
        
        // exit
        else if (EXIT.equals(line)) {
          scanner.close();
          System.exit(0);
        } else { 
          System.out.println(ResponseCode.WRITING_NOT_SUPPORTED);
        }
      } catch (StatusRuntimeException e) {
        System.out.println("Caught exception with description: " + e.getStatus().getDescription());
      }
		}
  }

  public static String concatStudentName(String[] args){          
    String studentName = args[1]; 
    Integer argsLength = args.length;
    //Adds multiple names
    for(int i = 2; i < argsLength; i++){
      if (i < argsLength){
        studentName = studentName + " ";
        studentName = studentName.concat(args[i]);
      }
    }
    return studentName;
  }

  public static boolean verifyInput(String studentId, String studentName){
    if (studentId.length() != 9 || studentName.length() < 3 || studentName.length() > 30)
      return false;
    return true;        
  }
}
