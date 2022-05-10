package pt.ulisboa.tecnico.classes.classserver.domain;

import pt.ulisboa.tecnico.classes.contract.ClassesDefinitions.*;

import java.util.concurrent.ConcurrentHashMap;

public class Turma {
    private Integer capacity = 0;
    private boolean openEnrollments = false;
    private boolean isServerActive = true;
    private boolean isGossipActive = true; 
    private ClassState classState;
    public ConcurrentHashMap<String, String> studentsEnrolledList = new ConcurrentHashMap<>();
    public ConcurrentHashMap<String, String> studentsDiscardedList = new ConcurrentHashMap<>();

    public synchronized boolean getIsServerActive(){
        return isServerActive;
    }
    
    public synchronized void setIsServerActive(boolean flag){
        this.isServerActive = flag;
    }

    public synchronized boolean getIsGossipActive(){
        return isGossipActive;
    }
    
    public synchronized void setIsGossipActive(boolean flag){
        this.isGossipActive = flag;
    }

    public synchronized ClassState getClassState(){
        return classState;
    }

    public synchronized void setClassState(ClassState classState){
        this.classState = classState;
    }

    /*Professor Methods */
    public synchronized Integer getCapacity(){
        return capacity;
    }

    public synchronized void setCapacity(Integer newCapacity){
        this.capacity = newCapacity;
    }

    public synchronized boolean getOpenEnrollments(){
        return openEnrollments;
    }

    public synchronized void setOpenEnrollments(boolean newOpenEnrollment){
        this.openEnrollments = newOpenEnrollment;
    }

    public synchronized Integer getNumberOfStudentsEnrolled(){
        return studentsEnrolledList.size();
    }
    
    public synchronized Integer getNumberOfStudentsDiscarded(){
        return studentsDiscardedList.size();
    }

    public synchronized void cancelEnrollment(String studentId){
        String studentName = studentsEnrolledList.get(studentId);
        studentsEnrolledList.remove(studentId);
        studentsDiscardedList.put(studentId, studentName);
    }

    /*Student Methods*/
    public synchronized boolean isStudentEnrolled(String studentId){
        return studentsEnrolledList.containsKey(studentId);
    }

    public synchronized boolean isStudentDiscarded(String studentId){
        return studentsDiscardedList.containsKey(studentId);
    }

    public synchronized void removeStudentDiscardedList(String studentId, String studentName){
        studentsDiscardedList.remove(studentId, studentName);           
    }

    public synchronized void enroll(String studentId, String studentName){
        studentsEnrolledList.put(studentId, studentName);
    }
    
    public synchronized void discard(String studentId, String studentName){
        studentsDiscardedList.put(studentId, studentName);
    }

    public synchronized ConcurrentHashMap<String, String> getEnrolledList() { return studentsEnrolledList; }

    public synchronized ConcurrentHashMap<String, String> getDiscardedList() { return studentsDiscardedList; }

    public synchronized void removeEnrolledListEntry(String studentId){
        studentsEnrolledList.remove(studentId);
    }

}
