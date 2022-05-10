package pt.ulisboa.tecnico.classes.namingserver.domain;

import java.util.concurrent.ConcurrentHashMap;
import java.util.Set;
import java.util.List;
import java.util.ArrayList;

public class NamingServices {
    ConcurrentHashMap<String, ServiceEntry> namingService = new ConcurrentHashMap<>();
    ServiceEntry serviceEntry = new ServiceEntry();

    public synchronized ConcurrentHashMap<String, ServiceEntry> getNamingService(){
        return namingService;
    }

    public synchronized void register(String service, String host, Integer port, String qualifier){
        serviceEntry.addServerEntry(host, port, qualifier);
        namingService.put(service, serviceEntry);        
    }
    
    public synchronized List<ServerEntry> lookup(String service, List<String> qualifiers) {
        serviceEntry = namingService.get(service);
        Set<ServerEntry> serverEntries = serviceEntry.getServerEntries();
        List<ServerEntry> newServerEntriesList = new ArrayList<ServerEntry>();
        //Verify if it is a service
        if (!namingService.containsKey(service)){
            return newServerEntriesList;
        }
        //Primary qualifier
        else if (qualifiers.size() == 1) {
            String qualifier = qualifiers.get(0);
            List<ServerEntry> serverEntriesArrayList = new ArrayList<ServerEntry>(serverEntries);
           
            for (int i = 0; i < serverEntriesArrayList.size(); i++){
                if (serverEntriesArrayList.get(i).getQualifier().equals(qualifier)){
                    newServerEntriesList.add(serverEntriesArrayList.get(i));
                }
            }
            return newServerEntriesList;
        }
        //Return entire list for both primary and secondary qualifiers or none
        else {
            List<ServerEntry> serverEntriesArrayList = new ArrayList<ServerEntry>(serverEntries);
            return serverEntriesArrayList;
        }     
    }

    public synchronized void delete(String service, String host, Integer port) {
        String qualifier = null;
        if(namingService.containsKey(service)) {
            Set<ServerEntry> serverEntries = serviceEntry.getServerEntries();
            List<ServerEntry> serverEntriesArrayList = new ArrayList<ServerEntry>(serverEntries);
            for(int i = 0; i < serverEntriesArrayList.size(); i++){
                if (serverEntriesArrayList.get(i).getHost().equals(host) && serverEntriesArrayList.get(i).getPort().equals(port)){   
                    qualifier = serverEntriesArrayList.get(i).getQualifier();    
                }
            } 
            serverEntries = serviceEntry.removeServerEntry(host, port, qualifier); 
            serviceEntry.setServerEntries(serverEntries);
            namingService.replace(service, serviceEntry);  
        }
    }
}
