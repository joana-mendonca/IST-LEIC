package sth.app.person;

import pt.tecnico.po.ui.Command;
import pt.tecnico.po.ui.Display;
import sth.core.Person;
import sth.core.SchoolManager;

import java.util.ArrayList;
import java.util.Iterator;

//FIXME import other classes if needed

/**
 * 4.2.3. Show all persons.
 */
public class DoShowAllPersons extends Command<SchoolManager> {

    //FIXME add input fields if needed

    /**
     * @param receiver
     */
    public DoShowAllPersons(SchoolManager receiver) {
        super(Label.SHOW_ALL_PERSONS, receiver);
    }

    /**
     * @see pt.tecnico.po.ui.Command#execute()
     */
    @Override
    public final void execute() {
        ArrayList<Person> toShow = _receiver.getAllUsers();

        Iterator<Person> it = toShow.iterator();
        while (it.hasNext()) {
            _display.addLine(it.next().toString());
        }

        _display.display();
    }

}
