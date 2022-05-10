package pt.ulisboa.tecnico.classes.namingserver;

import java.io.IOException;

import io.grpc.BindableService;
import io.grpc.Server;
import io.grpc.ServerBuilder;

public class NamingServer {

  public static void main(String[] args) throws IOException, InterruptedException{
    System.out.println(NamingServer.class.getSimpleName());
    System.out.printf("Received %d Argument(s)%n", args.length);
    for (int i = 0; i < args.length; i++) {
      System.out.printf("args[%d] = %s%n", i, args[i]);
    }
    boolean isDebugActive = false;
    int port = 0;
    if (args.length == 2){
      port = Integer.valueOf(args[1]);
    }
    else if(args.length == 3 && args[0].equals("-debug")){
      isDebugActive = true;
      port = Integer.valueOf(args[2]);

    }

    final BindableService namingServerService = new NamingServerServiceImpl(isDebugActive);

    // Create a new server to listen on port 5000
    if((args.length == 2 || args.length == 3) && port == 5000){
      Server server = ServerBuilder.forPort(port).addService(namingServerService).build();

      // Start the server.
      server.start();
      
      // Server threads are running in the background.
      //Log.info("Server started at port: " + port);
      System.out.println("Server started");

      // Do not exit the main thread. Wait until server is terminated.
      server.awaitTermination();
    } else {
      System.out.println("Unable to connect to port given");
    }
  }
}
