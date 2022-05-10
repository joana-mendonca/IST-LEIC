package pt.ulisboa.tecnico.classes.admin;

import java.util.Scanner;

import pt.ulisboa.tecnico.classes.namingserver.frontend.NamingServerFrontend;
import pt.ulisboa.tecnico.classes.contract.ClassesDefinitions.ResponseCode;
import pt.ulisboa.tecnico.classes.contract.admin.AdminServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.admin.AdminClassServer.*;
import pt.ulisboa.tecnico.classes.Stringify;

import io.grpc.StatusRuntimeException;

public class AdminClient {
  private static final String service = "turmas";
  private static final String ACTIVATE = "activate";
  private static final String DEACTIVATE = "deactivate";
  private static final String ACTIVATEGOSSIP = "activateGossip";
  private static final String DEACTIVATEGOSSIP = "deactivateGossip";
  private static final String GOSSIP = "gossip";
  private static final String DUMP = "dump";
  private static final String EXIT = "exit";

  public static void main(String[] args) {
    NamingServerFrontend namingServerFrontend = new NamingServerFrontend();
    
    Scanner scanner = new Scanner(System.in);

    while (true) {
      System.out.printf("> ");
      try{
        String line = scanner.nextLine();
        String[] input = line.split(" ");
        
        //activate
        if(ACTIVATE.equals(input[0])) {          
          if(input.length == 1 || input[1].equals("P"))
            activate(service, "P", namingServerFrontend); 
          else if(input[1].equals("S"))
            activate(service, "S", namingServerFrontend); 
          else
            System.out.println("Server not available");
        }

        //deactivate
        else if(DEACTIVATE.equals(input[0])) {
          if(input.length == 1 || input[1].equals("P"))
            deactivate(service, "P", namingServerFrontend); 
          else if(input[1].equals("S"))
            deactivate(service, "S", namingServerFrontend);
          else
            System.out.println("Server not available");          
        }

        //dump
        else if (DUMP.equals(input[0])) {         
          if(input.length == 1 || input[1].equals("P"))
            dump(service, "P", namingServerFrontend); 
          else if(input[1].equals("S"))
            dump(service, "S", namingServerFrontend);  
          else
            System.out.println("Server not available");      
        }

        //activateGossip
        else if (ACTIVATEGOSSIP.equals(input[0])) {         
          if(input.length == 1 || input[1].equals("P"))
            activateGossip(service, "P", namingServerFrontend); 
          else if(input[1].equals("S"))
            activateGossip(service, "S", namingServerFrontend);  
          else
            System.out.println("Server not available");      
        }

        //deactivateGossip
        else if (DEACTIVATEGOSSIP.equals(input[0])) {         
          if(input.length == 1 || input[1].equals("P"))
            deactivateGossip(service, "P", namingServerFrontend); 
          else if(input[1].equals("S"))
            deactivateGossip(service, "S", namingServerFrontend);  
          else
            System.out.println("Server not available"); 
        }

        //gossip
        else if (GOSSIP.equals(input[0])) {         
          if(input.length == 1 || input[1].equals("P"))
            gossip(service, "P", namingServerFrontend); 
          else if(input[1].equals("S"))
            gossip(service, "S", namingServerFrontend);  
          else
            System.out.println("Server not available"); 
        }

        //exit
        else if (EXIT.equals(line)) {
          scanner.close();
          System.exit(0);
        } else {
          System.out.println("No server available");
        }
      } catch (StatusRuntimeException e) {
        System.out.println("Caught exception with description: " + e.getStatus().getDescription());
      }
    }
  }

  public static void activate(String service, String qualifier, NamingServerFrontend namingServerFrontend){
    final AdminServiceGrpc.AdminServiceBlockingStub adminStub = namingServerFrontend.adminConnectsToServer(service, qualifier);
    ActivateResponse response = adminStub.activate(ActivateRequest.newBuilder().build());
    System.out.println(Stringify.format(response.getCode()) + "\n");   
  }

  public static void deactivate(String service, String qualifier, NamingServerFrontend namingServerFrontend){
    final AdminServiceGrpc.AdminServiceBlockingStub adminStub = namingServerFrontend.adminConnectsToServer(service, qualifier);
    DeactivateResponse response = adminStub.deactivate(DeactivateRequest.newBuilder().build());
    System.out.println(Stringify.format(response.getCode()) + "\n");     
  }

  public static void dump(String service, String qualifier, NamingServerFrontend namingServerFrontend){
    final AdminServiceGrpc.AdminServiceBlockingStub adminStub = namingServerFrontend.adminConnectsToServer(service, qualifier);
    DumpResponse response = adminStub.dump(DumpRequest.newBuilder().build());
    if (response.getCode().equals(ResponseCode.OK))
      System.out.println(Stringify.format(response.getClassState()) + "\n");   
  }

  public static void deactivateGossip(String service, String qualifier, NamingServerFrontend namingServerFrontend){
    final AdminServiceGrpc.AdminServiceBlockingStub adminStub = namingServerFrontend.adminConnectsToServer(service, qualifier);
    DeactivateGossipResponse response = adminStub.deactivateGossip(DeactivateGossipRequest.newBuilder().build());
    System.out.println(Stringify.format(response.getCode()) + "\n");  
  }

  public static void activateGossip(String service, String qualifier, NamingServerFrontend namingServerFrontend){
    final AdminServiceGrpc.AdminServiceBlockingStub adminStub = namingServerFrontend.adminConnectsToServer(service, qualifier);
    ActivateGossipResponse response = adminStub.activateGossip(ActivateGossipRequest.newBuilder().build());
    System.out.println(Stringify.format(response.getCode()) + "\n");    
  }

  public static void gossip(String service, String qualifier, NamingServerFrontend namingServerFrontend){
    final AdminServiceGrpc.AdminServiceBlockingStub adminStub = namingServerFrontend.adminConnectsToServer(service, qualifier);
    GossipResponse response = adminStub.gossip(GossipRequest.newBuilder().setQualifier(qualifier).build());
    System.out.println(Stringify.format(response.getCode()) + "\n");    
  }
}
