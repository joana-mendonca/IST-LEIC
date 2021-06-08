package sth.core;

import sth.core.exception.BadEntryException;

import java.util.ArrayList;
import java.util.HashMap;

public class Student extends Person{
	private boolean _isRepresentative;
	private Course _course;
	private ArrayList<Discipline> _disciplines;
	private HashMap<Project, Submission> _projSubmissions;

	public Student(int id, int phone, String name, boolean rep){
		super(id, phone, name);
		_isRepresentative = rep;
	}

	Course getCourse(){
		return _course;
	}

	void addDiscipline(Discipline discipline){
		_disciplines.add(discipline);
	}

	void setRepresentative(boolean rep){
		_isRepresentative = rep;
	}

	boolean isRepresentative(){
		return _isRepresentative;
	}

	void SubmitProject(Project p, Submission sub){
		_projSubmissions.put(p, sub);
	}

	@Override
	void parseContext(String lineContext, School school) throws BadEntryException {
		String components[] =  lineContext.split("\\|");

		if (components.length != 2)
			throw new BadEntryException("Invalid line context " + lineContext);

		if (_course == null) {
			_course = school.parseCourse(components[0]);
			_course.addStudent(this);
		}

		Discipline dis = _course.parseDiscipline(components[1]);

		if(_disciplines.size() > 6){
			//TODO Exception
			addDiscipline(dis);
		}

		dis.enrollStudent(this);
	}
	
	@Override
	public String toString(){
		String resultado;
		resultado = _isRepresentative ? "DELEGADO|" : "ALUNO|";
		return resultado + super.toString();
	}
}