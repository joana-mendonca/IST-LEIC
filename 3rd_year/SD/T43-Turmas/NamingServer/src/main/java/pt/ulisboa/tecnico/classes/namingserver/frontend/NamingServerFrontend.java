package pt.ulisboa.tecnico.classes.namingserver.frontend;

import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;

import pt.ulisboa.tecnico.classes.contract.naming.ClassServerNamingServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.naming.ClassServerNamingServer.*;
import pt.ulisboa.tecnico.classes.contract.classserver.ClassServerServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.admin.AdminServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.professor.ProfessorServiceGrpc;
import pt.ulisboa.tecnico.classes.contract.student.StudentServiceGrpc;

import java.util.List;
import java.util.ArrayList;
import java.util.Random;

public class NamingServerFrontend {
    //Constructor
    public NamingServerFrontend(){}
    //Create a channel
    final ManagedChannel namingServerChannel = ManagedChannelBuilder.forAddress("localhost", 5000).usePlaintext().build();
    // Create a blocking stub for naming server
    final ClassServerNamingServiceGrpc.ClassServerNamingServiceBlockingStub namingServerStub = ClassServerNamingServiceGrpc.newBlockingStub(namingServerChannel);

    //ClassServer
    public ClassServerServiceGrpc.ClassServerServiceBlockingStub classServerConnectsToServer(String service, String qualifier) {
      List<String> qualifiers = new ArrayList<String>();
      if (qualifier.equals("P"))
        qualifiers.add("S");
      else if (qualifier.equals("S"))
        qualifiers.add("P");
      
      //Connect to server
      LookupResponse lookupResponse = namingServerStub.lookup(LookupRequest.newBuilder().setService(service).addAllQualifiers(qualifiers).build());
      List<Server> serversList = lookupResponse.getHostPortList();
      
      if (!serversList.isEmpty()){
        Server server = getRandomServer(serversList);
        String host = server.getHost();
        Integer port = server.getPort();
        final ManagedChannel channel = ManagedChannelBuilder.forAddress(host, port).usePlaintext().build();
        final ClassServerServiceGrpc.ClassServerServiceBlockingStub classServerStub = ClassServerServiceGrpc.newBlockingStub(channel);
        return classServerStub;
      } else {
        return null;
      }
    }

    //Admin
    public AdminServiceGrpc.AdminServiceBlockingStub adminConnectsToServer(String service, String qualifier){
        List<String> qualifiers = new ArrayList<String>();
        qualifiers.add(qualifier);
        LookupResponse lookupResponse = namingServerStub.lookup(LookupRequest.newBuilder().setService(service).addAllQualifiers(qualifiers).build());
        List<Server> servers = lookupResponse.getHostPortList();			          
        if (!servers.isEmpty()){
          Server server = getRandomServer(servers);
          String host = server.getHost();
          Integer port = server.getPort();
    
          //Create new channel 
          final ManagedChannel channel = ManagedChannelBuilder.forAddress(host, port).usePlaintext().build();
          final AdminServiceGrpc.AdminServiceBlockingStub adminStub = AdminServiceGrpc.newBlockingStub(channel);
          return adminStub;
        } else {
          return null;
        }
    }

    //Professor
    public ProfessorServiceGrpc.ProfessorServiceBlockingStub professorConnectsToServer(String service, List<String> qualifiers){
        LookupResponse lookupResponse = namingServerStub.lookup(LookupRequest.newBuilder().setService(service).addAllQualifiers(qualifiers).build());
        List<Server> servers = lookupResponse.getHostPortList();			          
        if (!servers.isEmpty()){
          Server server = getRandomServer(servers);
          String host = server.getHost();
          Integer port = server.getPort();
    
          //Create new channel 
          final ManagedChannel channel = ManagedChannelBuilder.forAddress(host, port).usePlaintext().build();
          final ProfessorServiceGrpc.ProfessorServiceBlockingStub professorStub = ProfessorServiceGrpc.newBlockingStub(channel);
          return professorStub;
        } else {
          return null;
        }
    }

    //Student  
    public StudentServiceGrpc.StudentServiceBlockingStub studentConnectsToServer(String service, List<String> qualifiers){
    LookupResponse lookupResponse = namingServerStub.lookup(LookupRequest.newBuilder().setService(service).addAllQualifiers(qualifiers).build());
        List<Server> servers = lookupResponse.getHostPortList();			          
        if (!servers.isEmpty()){
            Server server = getRandomServer(servers);
            String host = server.getHost();
            Integer port = server.getPort();

            //Create new channel 
            final ManagedChannel channel = ManagedChannelBuilder.forAddress(host, port).usePlaintext().build();
            final StudentServiceGrpc.StudentServiceBlockingStub studentStub = StudentServiceGrpc.newBlockingStub(channel);
            return studentStub;
        } else {
            return null;
        }
    }
    
    public static Server getRandomServer(List<Server> servers){
        Random rand = new Random(); 
        int index = rand.nextInt(servers.size());
        return servers.get(index);
    }
}
