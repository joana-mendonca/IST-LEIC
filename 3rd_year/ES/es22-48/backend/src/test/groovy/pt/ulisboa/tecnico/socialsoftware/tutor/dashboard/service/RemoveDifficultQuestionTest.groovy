package pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.service

import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.boot.test.context.TestConfiguration
import pt.ulisboa.tecnico.socialsoftware.tutor.BeanConfiguration
import pt.ulisboa.tecnico.socialsoftware.tutor.SpockTest
import pt.ulisboa.tecnico.socialsoftware.tutor.auth.domain.AuthUser
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.domain.Dashboard
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.domain.DifficultQuestion
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.domain.SameDifficulty
import pt.ulisboa.tecnico.socialsoftware.tutor.exceptions.TutorException
import pt.ulisboa.tecnico.socialsoftware.tutor.question.domain.MultipleChoiceQuestion
import pt.ulisboa.tecnico.socialsoftware.tutor.question.domain.Option
import pt.ulisboa.tecnico.socialsoftware.tutor.question.domain.Question
import pt.ulisboa.tecnico.socialsoftware.tutor.user.domain.Student
import pt.ulisboa.tecnico.socialsoftware.tutor.utils.DateHandler
import spock.lang.Unroll

import static pt.ulisboa.tecnico.socialsoftware.tutor.exceptions.ErrorMessage.*

@DataJpaTest
class RemoveDifficultQuestionTest extends SpockTest {
    def student
    def dashboard
    def question
    def optionOK
    def optionKO
    def percentage
    def sameDifficulty

    def setup() {
        createExternalCourseAndExecution()

        student = new Student(USER_1_NAME, USER_1_USERNAME, USER_1_EMAIL, false, AuthUser.Type.EXTERNAL)
        student.addCourse(externalCourseExecution)
        userRepository.save(student)

        question = new Question()
        question.setKey(1)
        question.setTitle(QUESTION_1_TITLE)
        question.setContent(QUESTION_1_CONTENT)
        question.setStatus(Question.Status.AVAILABLE)
        question.setNumberOfAnswers(2)
        question.setNumberOfCorrect(1)
        question.setCourse(externalCourse)
        def questionDetails = new MultipleChoiceQuestion()
        question.setQuestionDetails(questionDetails)
        questionDetailsRepository.save(questionDetails)
        questionRepository.save(question)

        optionOK = new Option()
        optionOK.setContent(OPTION_1_CONTENT)
        optionOK.setCorrect(true)
        optionOK.setSequence(0)
        optionOK.setQuestionDetails(questionDetails)
        optionRepository.save(optionOK)

        optionKO = new Option()
        optionKO.setContent(OPTION_1_CONTENT)
        optionKO.setCorrect(false)
        optionKO.setSequence(1)
        optionKO.setQuestionDetails(questionDetails)
        optionRepository.save(optionKO)

        dashboard = new Dashboard(externalCourseExecution, student)
        dashboardRepository.save(dashboard)
    }

    def "student removes a difficult question from the dashboard with daysSince=#daysSince"() {
        given:
        def difficultQuestion = new DifficultQuestion()
        difficultQuestion.setDashboard(dashboard)
        difficultQuestion.setQuestion(question)
        difficultQuestion.setPercentage(24)
        difficultQuestion.setRemovedDate(DateHandler.now().minusDays(daysSince))
        difficultQuestion.setRemoved(true)
        difficultQuestionRepository.save(difficultQuestion)

        when:
        difficultQuestionService.removeDifficultQuestion(difficultQuestion.getId())

        then:
        difficultQuestionRepository.count() == 0
        and:
        def dashboard = dashboardRepository.getById(dashboard.getId())
        dashboard.getDifficultQuestions().size() == 0

        where:
        daysSince << [0, 1, 6]
    }

    def "T2 - student removes a difficult question from the dashboard with daysSince=#daysSince"() {
        given:
        def difficultQuestion = new DifficultQuestion(dashboard, question, 24)
        difficultQuestion.setRemovedDate(DateHandler.now().minusDays(daysSince))
        difficultQuestion.setRemoved(true)
        difficultQuestionRepository.save(difficultQuestion)

        when:
        difficultQuestionService.removeDifficultQuestion(difficultQuestion.getId())

        then:
        difficultQuestionRepository.count() == 0
        and:
        def dashboard = dashboardRepository.getById(dashboard.getId())
        dashboard.getDifficultQuestions().size() == 0

        where:
        daysSince << [0, 1, 6]
    }

    def "T3 - student creates a difficultQuestion"() {
        given:
        percentage = 2

        when:
        difficultQuestionService.createDifficultQuestions(dashboard.getId(), question.getId(), percentage)

        then:
        difficultQuestionRepository.count() == 1
        and:
        def dashboard = dashboardRepository.getById(dashboard.getId())
        dashboard.getDifficultQuestions().size() == 1

    }

    def "T4 - student tries to create a difficultQuestion with less than 0 percentage"() {
        given:
        percentage = -27

        when:
        difficultQuestionService.createDifficultQuestions(dashboard.getId(), question.getId(), percentage)

        then:
        def exception = thrown(TutorException)
        exception.getErrorMessage() == errorMessage
        and:
        difficultQuestionRepository.count() == 0

        where:
        errorMessage = CANNOT_CREATE_DIFFICULT_QUESTION

    }

    def "T5 - student tries to create a difficultQuestion with more than the allowed percentage"() {
        given:
        percentage = 37

        when:
        difficultQuestionService.createDifficultQuestions(dashboard.getId(), question.getId(), percentage)

        then:
        def exception = thrown(TutorException)
        exception.getErrorMessage() == errorMessage
        and:
        difficultQuestionRepository.count() == 0

        where:
        errorMessage = CANNOT_CREATE_DIFFICULT_QUESTION

    }

    
    def "T6 - student tries to create 2 difficultQuestion with the same percentage"() {
        given:
        percentage = 15
        def difficultQuestion = new DifficultQuestion(dashboard, question, percentage)
        difficultQuestionRepository.save(difficultQuestion)

        def question1 = new Question()    
        question1.setKey(4)    
        question1.setTitle(QUESTION_1_TITLE)    
        question1.setContent(QUESTION_1_CONTENT)    
        question1.setStatus(Question.Status.AVAILABLE)    
        question1.setNumberOfAnswers(5)    
        question1.setNumberOfCorrect(2)    
        question1.setCourse(externalCourse)    
        def questionDetails1 = new MultipleChoiceQuestion()    
        question1.setQuestionDetails(questionDetails1)    
        questionDetailsRepository.save(questionDetails1)    
        questionRepository.save(question1)


        when:
        difficultQuestionService.createDifficultQuestions(dashboard.getId(), question1.getId(), percentage)

        then:
        difficultQuestionRepository.count() == 2
        and:
        def dashboard = dashboardRepository.getById(dashboard.getId())
        dashboard.getDifficultQuestions().size() == 2

    }

    def "T7 - student tries to create 2 difficultQuestion with different percentages"() {
        given:
        percentage = 15
        def difficultQuestion = new DifficultQuestion(dashboard, question, percentage)
        difficultQuestionRepository.save(difficultQuestion)

        percentage = 13
        def question1 = new Question()    
        question1.setKey(4)    
        question1.setTitle(QUESTION_1_TITLE)    
        question1.setContent(QUESTION_1_CONTENT)    
        question1.setStatus(Question.Status.AVAILABLE)    
        question1.setNumberOfAnswers(5)    
        question1.setNumberOfCorrect(2)    
        question1.setCourse(externalCourse)    
        def questionDetails1 = new MultipleChoiceQuestion()    
        question1.setQuestionDetails(questionDetails1)    
        questionDetailsRepository.save(questionDetails1)    
        questionRepository.save(question1)


        when:
        difficultQuestionService.createDifficultQuestions(dashboard.getId(), question1.getId(), percentage)

        then:
        difficultQuestionRepository.count() == 2
        and:
        def dashboard = dashboardRepository.getById(dashboard.getId())
        dashboard.getDifficultQuestions().size() == 2

    }

    def "T8 - student creates a difficultQuestion with updated percentage"() {
        given:
        percentage = 2
        def difficultQuestion = new DifficultQuestion(dashboard, question, percentage)
        question.setNumberOfAnswers(5) 

        when:
        difficultQuestion.update()

        then:
        difficultQuestionRepository.count() == 1
        and:
        def dashboard = dashboardRepository.getById(dashboard.getId())
        dashboard.getDifficultQuestions().size() == 1

    }

    
    def "T9 - student removes a difficult question through SameDifficulty"() {
        given:
        def difficultQuestion = new DifficultQuestion(dashboard, question, 24)
        difficultQuestion.setRemovedDate(DateHandler.now().minusDays(daysSince))
        difficultQuestion.setRemoved(true)
        difficultQuestionRepository.save(difficultQuestion)

        when:
        difficultQuestion.getSameDifficulty().remove(difficultQuestion)
        difficultQuestionRepository.delete(difficultQuestion)

        then:
        difficultQuestionRepository.count() == 0

        where:
        daysSince << [0, 1, 6]

    }

    def "T10 - student tries to create SameDifficulty with null DifficultQuestion"() {
        given:
        def difficultQuestion = null

        when:
        def sameDifficulty = new SameDifficulty(difficultQuestion)

        then:
        def exception = thrown(TutorException)
        exception.getErrorMessage() == errorMessage

        where:
        errorMessage = DIFFICULT_QUESTION_IS_NULL

    }

    @Unroll
    def "the difficult question cannot be deleted days before #daysSince or not removed #removed"() {
        given: "a difficult question"
        def difficultQuestion = new DifficultQuestion()
        difficultQuestion.setDashboard(dashboard)
        difficultQuestion.setQuestion(question)
        difficultQuestion.setPercentage(24)
        difficultQuestion.setRemovedDate(DateHandler.now().minusDays(daysSince))
        difficultQuestion.setRemoved(removed)
        difficultQuestionRepository.save(difficultQuestion)

        when:
        difficultQuestionService.removeDifficultQuestion(difficultQuestion.getId())

        then:
        def exception = thrown(TutorException)
        exception.getErrorMessage() == errorMessage
        and:
        difficultQuestionRepository.count() == 1

        where:
        removed | daysSince || errorMessage
        false   | 0         || CANNOT_REMOVE_DIFFICULT_QUESTION
        true    | 7         || CANNOT_REMOVE_DIFFICULT_QUESTION
        true    | 8         || CANNOT_REMOVE_DIFFICULT_QUESTION
    }

    @Unroll
    def "the difficult question cannot be deleted because invalid difficultQuestionId #id"() {
        when:
        difficultQuestionService.removeDifficultQuestion(id)

        then: "an exception is thrown"
        def exception = thrown(TutorException)
        exception.getErrorMessage() == errorMessage

        where:
        id  || errorMessage
        0   || DIFFICULT_QUESTION_NOT_FOUND
        100 || DIFFICULT_QUESTION_NOT_FOUND
    }

    @TestConfiguration
    static class LocalBeanConfiguration extends BeanConfiguration {}
}