package pt.ulisboa.tecnico.classes.namingserver;

import pt.ulisboa.tecnico.classes.contract.naming.ClassServerNamingServiceGrpc;
//import pt.ulisboa.tecnico.classes.contract.naming.ClassServerNamingServiceGrpc.ClassServerNamingServiceImplBase;
import pt.ulisboa.tecnico.classes.namingserver.domain.NamingServices;
import pt.ulisboa.tecnico.classes.namingserver.domain.ServerEntry;
import pt.ulisboa.tecnico.classes.namingserver.domain.ServiceEntry;
import pt.ulisboa.tecnico.classes.contract.naming.ClassServerNamingServer.*;

import io.grpc.stub.StreamObserver;

import java.util.Set;
import java.util.List;
import java.util.ArrayList;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

public class NamingServerServiceImpl extends ClassServerNamingServiceGrpc.ClassServerNamingServiceImplBase {
    private NamingServices namingService = new NamingServices();
    private boolean isDebugActive;
    Logger log = Logger.getLogger(NamingServerServiceImpl.class.getName());

    //Constructor
    public NamingServerServiceImpl(boolean flag){
        isDebugActive = flag;
    }
   
    @Override
    public void register(RegisterRequest request, StreamObserver<RegisterResponse> responseObserver){
        String service = request.getService();
        String host = request.getHost();
        Integer port = Integer.valueOf(request.getPort());
        String qualifier = String.valueOf(request.getQualifier());
        namingService.register(service, host, port, qualifier);
        RegisterResponse response = RegisterResponse.getDefaultInstance();
        responseObserver.onNext(response);
        responseObserver.onCompleted();
        printDebugMessage(log, service, host, port, 1, isDebugActive);
    }

    @Override
    public void lookup(LookupRequest request, StreamObserver<LookupResponse> responseObserver){
        String service = request.getService();
        List<String> qualifiers = request.getQualifiersList();

        /*List of server entries containing the given qualifier */
        List<ServerEntry> serverEntries = namingService.lookup(service, qualifiers);
        List<Server> servers = new ArrayList<Server>();
        if (!serverEntries.isEmpty()){
            for(int i = 0; i < serverEntries.size(); i++){
                String host = serverEntries.get(i).getHost();
                Integer port = serverEntries.get(i).getPort();
                servers.add(Server.newBuilder().setHost(host).setPort(port).build());    
            }
        }

        LookupResponse response = LookupResponse.newBuilder().addAllHostPort(servers).build();
        responseObserver.onNext(response);
        responseObserver.onCompleted();
        //printDebugMessage(log, service, null, null, 2, isDebugActive);    
    }

    @Override
    public void delete(DeleteRequest request, StreamObserver<DeleteResponse> responseObserver) {
        String service = request.getService();
        String host = request.getHost();
        Integer port = Integer.valueOf(request.getPort());     
        
        namingService.delete(service, host, port);
        
        DeleteResponse response = DeleteResponse.getDefaultInstance();
        responseObserver.onNext(response);
        responseObserver.onCompleted();
        printDebugMessage(log, service, host, port, 3, isDebugActive);
    }

    public void printServerEntries(String service){
        ConcurrentHashMap<String, ServiceEntry> namingServices = namingService.getNamingService();
            
        ServiceEntry serviceEntry = namingServices.get(service);
        Set<ServerEntry> serverEntries = serviceEntry.getServerEntries();
        List<ServerEntry> serverEntriesArrayList = new ArrayList<ServerEntry>(serverEntries);
        
        System.out.println("---------------------------------------------------");
        System.out.println("Server Entries List");
        for (int j = 0; j < serverEntries.size(); j++){
            System.out.println("\nServer " + j);
            String host = serverEntriesArrayList.get(j).getHost();
            System.out.println("Host: "+host);
            Integer port = serverEntriesArrayList.get(j).getPort();
            System.out.println("Port: "+port);
            String qualifier = serverEntriesArrayList.get(j).getQualifier();
            System.out.println("Qualifier: "+qualifier);
        }
        System.out.println("---------------------------------------------------");
    }

    public void printDebugMessage(Logger log, String service, String host, Integer port, Integer messageCode, boolean isDebugActive){
        if (isDebugActive == true){
            if(messageCode == 1){
                log.info("Register new server " + host + " on port " + port); 
                printServerEntries(service);     
            }   
            else if(messageCode == 2)
                log.info("Looking for available servers.");      
            else if(messageCode == 3){
                log.info("Delete server " + host + " on port " + port);   
                printServerEntries(service);
            } 
        }
    }
}
