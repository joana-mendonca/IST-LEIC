package sth.app.person;

import pt.tecnico.po.ui.Command;
import pt.tecnico.po.ui.Input;
import sth.core.Person;
import sth.core.SchoolManager;

import java.util.ArrayList;
import java.util.Iterator;

//FIXME import other classes if needed

/**
 * 4.2.4. Search person.
 */
public class DoSearchPerson extends Command<SchoolManager> {

  Input<String> _characters;
  
  /**
   * @param receiver
   */
  public DoSearchPerson(SchoolManager receiver) {
    super(Label.SEARCH_PERSON, receiver);
    _characters = _form.addStringInput(Message.requestPersonName());
  }

  /** @see pt.tecnico.po.ui.Command#execute() */
  @Override
  public final void execute() {
      _form.parse();

      ArrayList<Person> toShow = _receiver.searchPerson(_characters.value());

      Iterator<Person>  it = toShow.iterator();
      while (it.hasNext()){
          _display.addLine(it.next().toString());
      }

      _display.display();
  }

}
