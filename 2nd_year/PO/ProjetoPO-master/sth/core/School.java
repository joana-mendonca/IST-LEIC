package sth.core;

//FIXME import other classes if needed

import sth.core.exception.BadEntryException;
import sth.core.exception.NoSuchPersonIdException;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;

/**
 * School implementation.
 */
public class School implements java.io.Serializable {

  /** Serial number for serialization. */
  private static final long serialVersionUID = 201810051538L;

  //FIXME define object fields (attributes and, possibly, associations)
  private String _name;
  private ArrayList<Person> _users;
  private ArrayList<Course> _courses;
  private static int _nextPersonId = 100000;

  //FIXME implement constructors if needed
    public School(){
        _name = "PlaceHolder Name";
        _nextPersonId ++;
        _users = new ArrayList<>();
        _courses = new ArrayList<>();
    }
  
  /**
   * @param filename
   * @throws BadEntryException
   * @throws IOException
   */
  void importFile(String filename) throws IOException, BadEntryException {
      Parser parser = new Parser(this);
      parser.parseFile(filename);
  }
  
  //FIXME implement other methods
  Person getPerson(int personId) throws NoSuchPersonIdException {
      Iterator<Person>  it = _users.iterator();
      while (it.hasNext()) {
          if(it.next().getId() == personId)
              return it.next();
      }
      // if reaches here, id not found
      throw new NoSuchPersonIdException(personId);
  }

  void addPerson(Person person){
      _users.add(person);
  }

  void addCourse(Course course){
    _courses.add( course);
  }

  ArrayList<Person> getAllUsers(){
      return _users;
  }

  Course parseCourse(String lineContext){
      Course course = new Course(lineContext);
      if(_courses.indexOf(course) == -1)
          addCourse(course);
      return course;
  }
}
