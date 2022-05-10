package pt.ulisboa.tecnico.classes.classserver;

import java.io.IOException;
import java.util.Timer;
import java.util.TimerTask;

import pt.ulisboa.tecnico.classes.classserver.domain.Turma;
import pt.ulisboa.tecnico.classes.classserver.frontend.ClassServerFrontend;
import pt.ulisboa.tecnico.classes.contract.naming.ClassServerNamingServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.naming.ClassServerNamingServer.*;
import io.grpc.BindableService;
import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;


public class ClassServer {

  public static void main(String[] args) throws IOException, InterruptedException {
    System.out.println(ClassServer.class.getSimpleName());
    System.out.printf("Received %d Argument(s)%n", args.length);
    for (int i = 0; i < args.length; i++) {
      System.out.printf("args[%d] = %s%n", i, args[i]);
    }

    boolean isDebugActive = false;
    String host = null;
    int port = 0;
    String qualifier = null;
    final String service = "turmas";

    if (args.length == 3){
      host = String.valueOf(args[0]);
      port = Integer.valueOf(args[1]);
      qualifier = String.valueOf(args[2]);
    } 
    else if (args.length == 4 && args[0].equals("-debug")) {
      isDebugActive = true;
      host = String.valueOf(args[1]);
      port = Integer.valueOf(args[2]);
      qualifier = String.valueOf(args[3]);
    }

    //Use of a plain text connection to the naming server
    final ManagedChannel channel = ManagedChannelBuilder.forAddress("localhost", 5000).usePlaintext().build();

		// Create a blocking stub.
		final ClassServerNamingServiceGrpc.ClassServerNamingServiceBlockingStub namingServerStub = ClassServerNamingServiceGrpc.newBlockingStub(channel);
    RegisterResponse response = namingServerStub.register(RegisterRequest.newBuilder().setService(service).setHost(host).setPort(port).setQualifier(qualifier).build());    

    final Turma turma = new Turma();

		final BindableService professorService = new ProfessorServiceImpl(turma, isDebugActive);
    final BindableService studentService = new StudentServiceImpl(turma, isDebugActive);
    final BindableService adminService = new AdminServiceImpl(turma, isDebugActive);
    final BindableService classServerService = new ClassServerImpl(turma, isDebugActive);
    
    Server server = null;
    Timer timer = new Timer("Timer");
    ClassServerFrontend classServerFrontend = new ClassServerFrontend();
    try{
      // Create a new server to listen on port.
      server = ServerBuilder.forPort(port).addService(professorService).addService(studentService).addService(adminService).addService(classServerService).build();
   
      // Start the server.
      server.start();
      
      // Server threads are running in the background.
      System.out.println("Server started");
      
      final String propagateQualifier = qualifier;
      final String hostFinal = host;
      final Integer portFinal = port;
      timer.schedule(new TimerTask() {
        public void run() {
          boolean isGossipActive = turma.getIsGossipActive();
          if (isGossipActive == true){
            classServerFrontend.propagateState(turma, propagateQualifier); 
          } 
          else {
            try {
              Thread.sleep(4000);
            } catch (InterruptedException e) {
              return;
            }
          }      
        }
      }, 0, 60000);//wait 0 ms before doing the action and do it every minute
      
      Runtime.getRuntime().addShutdownHook(new Thread(){
        public void run(){
          DeleteResponse response = namingServerStub.delete(DeleteRequest.newBuilder().setService(service).setHost(hostFinal).setPort(portFinal).build());  
          timer.cancel();//stop the timer
        }
      });
      // Do not exit the main thread. Wait until server is terminated.
      server.awaitTermination();
      
    } catch (IOException e) {
      e.printStackTrace();
    } 
  }
}