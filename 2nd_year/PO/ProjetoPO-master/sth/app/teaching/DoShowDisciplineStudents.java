package sth.app.teaching;

import pt.tecnico.po.ui.Command;
import pt.tecnico.po.ui.DialogException;
import pt.tecnico.po.ui.Input;
import sth.app.common.Message;
import sth.app.exception.NoSuchDisciplineException;
import sth.core.SchoolManager;
import sth.core.Student;
import sth.core.exception.NoSuchDisciplineIdException;

import java.util.ArrayList;
import java.util.Iterator;

//FIXME import other classes if needed

/**
 * 4.4.4. Show course students.
 */
public class DoShowDisciplineStudents extends Command<SchoolManager> {

    Input<String> _discipline;

    /**
     * @param receiver
     */
    public DoShowDisciplineStudents(SchoolManager receiver) {
        super(Label.SHOW_COURSE_STUDENTS, receiver);
        _discipline = _form.addStringInput(Message.requestDisciplineName());
    }

    /**
     * @see pt.tecnico.po.ui.Command#execute()
     */
    @Override
    public final void execute() throws DialogException {
        _form.parse();

        try{
            ArrayList<Student> ds = _receiver.showDisciplineStudents(_discipline.value());
            Iterator<Student> it = ds.iterator();
            while (it.hasNext()) {
                _display.addLine(it.next().toString());
            }
            _display.display();
        } catch (NoSuchDisciplineIdException e){
            throw new NoSuchDisciplineException(e.getId());
        }
    }

}
