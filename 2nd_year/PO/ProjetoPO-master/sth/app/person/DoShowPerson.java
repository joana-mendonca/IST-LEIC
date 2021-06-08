package sth.app.person;

import pt.tecnico.po.ui.Command;
import pt.tecnico.po.ui.Display;
import pt.tecnico.po.ui.Input;
import sth.app.exception.NoSuchPersonException;
import sth.core.Person;
import sth.core.SchoolManager;
import sth.core.exception.NoSuchPersonIdException;

//FIXME import other classes if needed

/**
 * 4.2.1. Show person.
 */
public class DoShowPerson extends Command<SchoolManager> {

    Input<Integer> _id;

    /**
     * @param receiver
     */
    public DoShowPerson(SchoolManager receiver) {
        super(Label.SHOW_PERSON, receiver);
        _id = _form.addIntegerInput(Message.requestPersonId());
    }

    /**
     * @see pt.tecnico.po.ui.Command#execute()
     */
    @Override
    public final void execute() throws NoSuchPersonException {
        _form.parse();

        try{
            Person p = _receiver.showPerson(_id.value());
            _display.addLine(p.toString());
            _display.display();
        } catch(NoSuchPersonIdException e){
            throw new NoSuchPersonException(_id.value());
        }
    }

}
