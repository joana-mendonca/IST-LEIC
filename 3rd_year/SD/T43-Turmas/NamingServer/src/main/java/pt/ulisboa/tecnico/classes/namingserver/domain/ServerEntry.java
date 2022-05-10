package pt.ulisboa.tecnico.classes.namingserver.domain;

/*
 * Contains info related to each server
 */
public class ServerEntry {
    String host;
    Integer port;
    String qualifier;

    public ServerEntry(){}

    public synchronized String getHost(){
        return host;
    }
    public synchronized Integer getPort(){
        return port;
    }
    public synchronized String getQualifier(){
        return qualifier;
    }

    public synchronized void setHost(String newHost){
        this.host = newHost;
    }
    public synchronized void setPort(Integer newPort){
        this.port = newPort;
    }
    public synchronized void setQualifier(String newQualifier){
        this.qualifier = newQualifier;
    }

    @Override
    public int hashCode() {
        return host.hashCode() + port.hashCode() + qualifier.hashCode();
    }

    @Override
    public boolean equals(Object other){
        if (other == null)
            return false;
        if(other.getClass() != getClass())
            return false;
        ServerEntry entry = (ServerEntry) other;
        if (entry.getHost().equals(getHost()) && entry.getPort().equals(getPort()) && entry.getQualifier().equals(getQualifier()))
            return true;
        else
            return false;            
    }
}