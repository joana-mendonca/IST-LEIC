package sth.core;

import sth.core.exception.NoSuchProjectIdException;

import java.util.ArrayList;
import java.util.HashMap;

public class Discipline {
    private String _name;
    private int _capacity;
    private Course _course;
    private ArrayList<Student> _students;
    private ArrayList<Teacher> _teachers;
    private HashMap<String, Project> _projects;

    public Discipline(String n, Course c) {
        this._name = n;
        _capacity = -1;
        _course = c;
        _students = new ArrayList<>();
        _teachers = new ArrayList<>();
        _projects = new HashMap<String, Project>();
    }

    public String getName() {
        return _name;
    }

    Course getCourse() {
        return _course;
    }

    void addTeacher(Teacher t) {
        _teachers.add(t);
    }

    void enrollStudent(Student s) {
        if (_students.size() >= _capacity) {
            //TODO Exception
            return;
        }
        _students.add(s);
    }

    void createProject(String name, String desc) {
        Project p = new Project(name, desc, this);
        if(_projects.putIfAbsent(name, p) != null)
            //TODO exception
            ;
    }

    Project getProject(String name) throws NoSuchProjectIdException {
        Project p;
        p = _projects.get(name);

        if(p == null)
            throw new NoSuchProjectIdException(name);

        return p;
    }

    ArrayList<Student> getEnrolledStudents() {
        return _students;
    }
}
