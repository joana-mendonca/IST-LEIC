package pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.webservice

import groovyx.net.http.HttpResponseException
import groovyx.net.http.RESTClient
import org.apache.http.HttpStatus
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.web.server.LocalServerPort
import pt.ulisboa.tecnico.socialsoftware.tutor.auth.domain.AuthUser
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.domain.Dashboard
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.service.FailedAnswersSpockTest
import pt.ulisboa.tecnico.socialsoftware.tutor.user.domain.Student
import pt.ulisboa.tecnico.socialsoftware.tutor.user.domain.Teacher

import java.time.LocalDateTime

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class RemoveFailedAnswersWebServiceIT extends FailedAnswersSpockTest {
    @LocalServerPort
    private int port

    def response
    def courseExecution
    def quiz
    def quizQuestion
    def failedAnswer

    def setup() {
        given:
        restClient = new RESTClient("http://localhost:" + port)
        and:
        createExternalCourseAndExecution()
        and:
        student = new Student(USER_1_NAME, USER_1_EMAIL, USER_1_EMAIL, false, AuthUser.Type.EXTERNAL)
        student.authUser.setPassword(passwordEncoder.encode(USER_1_PASSWORD))
        student.addCourse(externalCourseExecution)
        userRepository.save(student)
        and:
        dashboard = new Dashboard(externalCourseExecution, student)
        dashboardRepository.save(dashboard)
        and:
        quiz = createQuiz(1)
        quizQuestion = createQuestion(1, quiz)
        def questionAnswer = answerQuiz(true, false, true, quizQuestion, quiz)
        failedAnswer = createFailedAnswer(questionAnswer, LocalDateTime.now().minusDays(8))

        
    }

    def "student gets failed answers from dashboard then removes it"() {
        given: 
        createdUserLogin(USER_1_EMAIL, USER_1_PASSWORD)

        when:
        response = restClient.delete(
                path: '/students/dashboards/' + dashboard.getId() +'/failedAnswers/' + failedAnswer.getId(),
                requestContentType: 'application/json'
        )
        
        then: "check the response status"
        response != null
        response.status == 200
        and: "it is removed from the database"
        failedAnswerRepository.findAll().size() == 0
    }

    def "teacher can't remove student's failed answers from dashboard"() {
        given: "a teacher"
        def teacher = new Teacher(USER_2_NAME, USER_2_EMAIL, USER_2_EMAIL, false, AuthUser.Type.EXTERNAL)
        teacher.authUser.setPassword(passwordEncoder.encode(USER_2_PASSWORD))
        teacher.addCourse(externalCourseExecution)
        userRepository.save(teacher)
        createdUserLogin(USER_2_EMAIL, USER_2_PASSWORD)

        when:
        response = restClient.delete(
                path: '/students/dashboards/' + dashboard.getId() +'/failedAnswers/' + failedAnswer.getId(),
                requestContentType: 'application/json'
        ) 
        
        then: "the response returns 403"
        def error = thrown(HttpResponseException)
        error.response.status == HttpStatus.SC_FORBIDDEN  
        and: "failed answer remains in the database"
        failedAnswerRepository.findAll().size() == 1

        cleanup:
        userRepository.deleteById(teacher.getId())
    }

    def "student can't get another student's failed answers from dashboard"() {
        given: "another student"
        def student2 = new Student(USER_2_NAME, USER_2_EMAIL, USER_2_EMAIL, false, AuthUser.Type.EXTERNAL)
        student2.authUser.setPassword(passwordEncoder.encode(USER_2_PASSWORD))
        student2.addCourse(externalCourseExecution)
        userRepository.save(student2)
        createdUserLogin(USER_2_EMAIL, USER_2_PASSWORD)

        when:
        response = restClient.delete(
                path: '/students/dashboards/' + dashboard.getId() +'/failedAnswers/' + failedAnswer.getId(),
                requestContentType: 'application/json'
        )

        then: "the response returns 403"
        def error = thrown(HttpResponseException)
        error.response.status == HttpStatus.SC_FORBIDDEN  
        and: "failed answer remains in the database"
        failedAnswerRepository.findAll().size() == 1

        cleanup:
        userRepository.deleteById(student2.getId())
    }

    def cleanup() {
        userRepository.deleteAll()
        dashboardRepository.deleteAll()
        courseRepository.deleteAll()
        quizRepository.deleteAll()
        questionRepository.deleteAll()
    }

}