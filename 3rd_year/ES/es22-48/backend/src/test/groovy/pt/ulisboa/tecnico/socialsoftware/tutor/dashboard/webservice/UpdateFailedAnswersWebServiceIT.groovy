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

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class UpdateFailedAnswersWebServiceIT extends FailedAnswersSpockTest {
    @LocalServerPort
    private int port

    def response
    def quiz
    def quizQuestion
    def questionAnswer

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
        questionAnswer = answerQuiz(true, false, true, quizQuestion, quiz)

    }

    def "student updates failed answers"() {
        given: 
        createdUserLogin(USER_1_EMAIL, USER_1_PASSWORD)

        when:
        response = restClient.put(
            path: '/students/dashboards/' + dashboard.getId(),
            requestContentType: 'application/json'
        )

        then: "check the response status"
        response != null
        response.status == 200
        and: "failed answer is updated in the database"
        failedAnswerRepository.findAll().size() == 1

    }

    def "teacher cant update student's failed answers"() {
        given: "a teacher"
        def teacher = new Teacher(USER_2_NAME, USER_2_EMAIL, USER_2_EMAIL, false, AuthUser.Type.EXTERNAL)
        teacher.authUser.setPassword(passwordEncoder.encode(USER_2_PASSWORD))
        teacher.addCourse(externalCourseExecution)
        userRepository.save(teacher)
        createdUserLogin(USER_2_EMAIL, USER_2_PASSWORD)

        when:
        response = restClient.put(
            path: '/students/dashboards/' + dashboard.getId(),
            requestContentType: 'application/json'
        )

        then: "the response returns 403"
        def error = thrown(HttpResponseException)
        error.response.status == HttpStatus.SC_FORBIDDEN  
        and: "failed answer is not updated"
        failedAnswerRepository.findAll().size() == 0

        cleanup:
        userRepository.deleteById(teacher.getId())
    }

    def "student cant update another students failed answers"() {
        given: "another student"
        def student2 = new Student(USER_2_NAME, USER_2_EMAIL, USER_2_EMAIL, false, AuthUser.Type.EXTERNAL)
        student2.authUser.setPassword(passwordEncoder.encode(USER_2_PASSWORD))
        student2.addCourse(externalCourseExecution)
        userRepository.save(student2)
        createdUserLogin(USER_2_EMAIL, USER_2_PASSWORD)

        when:
        response = restClient.put(
            path: '/students/dashboards/' + dashboard.getId(),
            requestContentType: 'application/json'
        )

        then: "the response returns 403"
        def error = thrown(HttpResponseException)
        error.response.status == HttpStatus.SC_FORBIDDEN  
        and: "failed answer is not updated"
        failedAnswerRepository.findAll().size() == 0

        cleanup:
        userRepository.deleteById(student2.getId())
    }
    
    def cleanup() {
        userRepository.deleteAll()
        courseRepository.deleteAll()
        quizRepository.deleteAll()
        questionRepository.deleteAll()
        failedAnswerRepository.deleteAll()
    }
}