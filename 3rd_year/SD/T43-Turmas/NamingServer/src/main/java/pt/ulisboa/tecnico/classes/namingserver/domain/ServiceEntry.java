package pt.ulisboa.tecnico.classes.namingserver.domain;

import java.util.Set;
import java.util.HashSet;

/*
 *
 * 
 */
public class ServiceEntry {
    private Set<ServerEntry> serverEntries = new HashSet<ServerEntry>();
    
    public ServiceEntry(){}

    public synchronized Set<ServerEntry> getServerEntries(){
        return serverEntries;
    } 

    public synchronized void setServerEntries(Set<ServerEntry> newServerEntries){
        serverEntries = newServerEntries;
    }

    public synchronized void addServerEntry(String host, Integer port, String qualifier){
        ServerEntry serverEntry = new ServerEntry();
        serverEntry.setHost(host);
        serverEntry.setPort(port);
        serverEntry.setQualifier(qualifier);
        if (!serverEntries.contains(serverEntry)){
            serverEntries.add(serverEntry);
        }
    }

    public synchronized Set<ServerEntry> removeServerEntry(String host, Integer port, String qualifier){
        ServerEntry serverEntry = new ServerEntry();
        serverEntry.setHost(host);
        serverEntry.setPort(port);
        serverEntry.setQualifier(qualifier);
        serverEntries.remove(serverEntry);    

        return serverEntries;
    }
}
