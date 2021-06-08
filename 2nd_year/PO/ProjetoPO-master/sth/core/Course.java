package sth.core;

import java.util.ArrayList;

public class Course{
	private String _name;
	private ArrayList<Discipline> _disciplines;
	private ArrayList<Student> _students;
	private int _representative;

	public Course(String name){
		_name = name;
	}

	public String getName(){
		return _name;
	} 

	void addDiscipline(Discipline discipline){
		_disciplines.add(discipline);
	}

	void addStudent(Student student){
		_students.add(student);

	}

	void addRepresentative(Student student){
		if(_representative > 7){
			return;
		}

		if (student.isRepresentative()){
			return;
		}

		student.setRepresentative(true);

		_representative++;
	}

	void removeRepresentative(Student student){
		if(student.isRepresentative()){
			student.setRepresentative(false);
			_representative--;
		}
		//FIXME exception
	}

	Discipline parseDiscipline(String context){
		Discipline d;
		d = new Discipline(context, this);

		if(_disciplines.indexOf(d) == -1)
			_disciplines.add(d);

		return d;
	}
}