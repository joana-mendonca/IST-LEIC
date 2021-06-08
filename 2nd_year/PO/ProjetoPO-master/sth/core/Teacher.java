package sth.core;

import sth.app.exception.NoSuchDisciplineException;
import sth.core.exception.NoSuchDisciplineIdException;
import sth.core.exception.BadEntryException;
import sth.core.exception.NoSuchProjectIdException;

import java.util.ArrayList;
import java.util.Iterator;

public class Teacher extends Person{
    private ArrayList<Discipline> _disciplines;

    public Teacher(int _id, int _phoneNumber, String _name) {
        super(_id, _phoneNumber, _name);
        _disciplines = new ArrayList<Discipline>();
    }

    void addDiscipline(Discipline d){
        _disciplines.add(d);
    }

    Discipline getDiscipline(String name) throws NoSuchDisciplineIdException {
        Discipline d = null;
        Iterator<Discipline> it = _disciplines.iterator();

        while (it.hasNext()) {
            if (it.next().getName().equals(name))
                d = it.next();
        }

        if (d == null)
            throw new NoSuchDisciplineIdException(name);

        return d;
    }

    void createProject(String disName, String projName) throws NoSuchDisciplineIdException {
        Discipline d =  getDiscipline(disName);

        d.createProject(projName, "Placeholder Description");
    }

    void closeProject(String disName, String projName) throws NoSuchProjectIdException, NoSuchDisciplineIdException {
        Discipline d = getDiscipline(disName);
        Project p = d.getProject(projName);
        p.close();
    }

    @Override
    public String toString() {
        //TODO
        return "DOCENTE|" + super.toString();
    }

    //TODO
    //ArrayList<Project> getProjectSubmissions(Discipline d){}

    ArrayList<Student> getStudentsOfDiscipline(Discipline d) throws NoSuchDisciplineIdException {
        // verificar se leciona disciplina
        if(_disciplines.indexOf(d) == -1){
            throw new NoSuchDisciplineIdException(d.getName());
        }

        // vai ao objeto disciplina
        // retorna o arraylist de alunos
        return d.getEnrolledStudents();
    }

    @Override
    void parseContext(String lineContext, School school) throws BadEntryException {
        String components[] =  lineContext.split("\\|");

        if (components.length != 2)
            throw new BadEntryException("Invalid line context " + lineContext);

        Course course = school.parseCourse(components[0]);
        Discipline discipline = course.parseDiscipline(components[1]);

        discipline.addTeacher(this);
    }
}
