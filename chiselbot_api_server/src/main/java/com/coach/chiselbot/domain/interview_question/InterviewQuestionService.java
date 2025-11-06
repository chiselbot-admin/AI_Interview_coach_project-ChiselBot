package com.coach.chiselbot.domain.interview_question;

import com.coach.chiselbot._global.errors.adminException.AdminException404;
import com.coach.chiselbot.domain.admin.Admin;
import com.coach.chiselbot.domain.admin.AdminRepository;
import com.coach.chiselbot.domain.interview_category.InterviewCategory;
import com.coach.chiselbot.domain.interview_category.InterviewCategoryRepository;
import com.coach.chiselbot.domain.interview_coach.EmbeddingService;
import com.coach.chiselbot.domain.interview_question.dto.QuestionRequest;
import com.coach.chiselbot.domain.interview_question.dto.QuestionResponse;
import com.google.gson.Gson;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class InterviewQuestionService {

    private final InterviewQuestionRepository interviewQuestionRepository;
    private final InterviewCategoryRepository interviewCategoryRepository;
    private final EmbeddingService embeddingService;
    private final AdminRepository adminRepository;
    private final InterviewQuestionRepository questionRepository;

    private final Gson gson = new Gson();

    /**
     * <p>전체 QuestionList 1p당 10개 게시물</p>
     * */
    @Transactional(readOnly = true)
    public Page<QuestionResponse.FindAll> getQuestionList(int page){
        int pageSize = 10;
        Pageable pageable = PageRequest.of(page, pageSize);

        return interviewQuestionRepository.findAll(pageable).map(QuestionResponse.FindAll::new);
    }

    public List<InterviewCategory> getAllCategories(){
        return interviewCategoryRepository.findAll();
    }

    @Transactional(readOnly = true)
    public QuestionResponse.FindById getQuestionDetail(Long questionId){
        InterviewQuestion interviewQuestion = interviewQuestionRepository.findById(questionId)
                .orElseThrow(()-> new AdminException404(" 해당 질문이 없습니다"));
        return new QuestionResponse.FindById(interviewQuestion);
    }

    /**
     * 카테고리 ID와 레벨을 기준으로 질문 한 건을 랜덤 조회
     */
    @Transactional(readOnly = true)
    public QuestionResponse.FindById getOneQuestion(Long categoryId, InterviewLevel level) {
        InterviewCategory category = interviewCategoryRepository.findById(categoryId)
                .orElseThrow(() -> new AdminException404("해당 카테고리를 찾을 수 없습니다"));

        Optional<InterviewQuestion> questionOpt =
                interviewQuestionRepository.findFirstByCategoryId_CategoryIdAndInterviewLevel(
                        category.getCategoryId(),
                        level
                );
        return questionOpt.map(QuestionResponse.FindById::fromEntity).orElse(null);
    }

    // Admin - 질문등록 기능
    public QuestionResponse.FindById createQuestion (QuestionRequest.CreateQuestion request){

        InterviewCategory category = interviewCategoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new AdminException404("해당 ID의 카테고리를 찾을 수 없습니다"));

        Admin admin = adminRepository.findById(request.getAdminId())
                .orElseThrow(() -> new AdminException404("해당 ID의 관리자를 찾을 수 없습니다"));

        InterviewQuestion newQuestion = new InterviewQuestion();

        newQuestion.setCategoryId(category);
        newQuestion.setAdminId(admin);
        newQuestion.setQuestionText(request.getQuestionText());
        newQuestion.setInterviewLevel(request.getInterviewLevel());

        // Level 1 문제일 때, answer과 answerVector 저장
        if (request.getInterviewLevel() == InterviewLevel.LEVEL_1) {
            newQuestion.setAnswerText(request.getAnswerText());

            if (request.getAnswerText() != null && !request.getAnswerText().isBlank()) {
                // 정답데이터 임베딩 후 gson 를 사용하여 Json 형태로 변환한 후 저장
                // 1. 임베딩
                float[] answerVector = embeddingService.embed(request.getAnswerText());
                // 2. gson 으로 String 형태의 Json 으로 변환
                String answerVectorJson = gson.toJson(answerVector);
                // 3. 저장
                newQuestion.setAnswerVector(answerVectorJson);
                questionRepository.save(newQuestion);
            }
        }
        // Level 2 이상일 때, intent, point와 각각의 Vector 값을 저장
        else {
            newQuestion.setIntentText(request.getIntentText());
            newQuestion.setPointText(request.getPointText());

//                if (request.getIntentText() != null && !request.getIntentText().isBlank() &&
//                        request.getPointText() != null && !request.getPointText().isBlank()) {
//                    // intentVector 임베딩 후 저장
//                    float[] intentVector = embeddingService.embed(request.getQuestionText());
//                    String intentVectorJson = gson.toJson(intentVector);
//                    newQuestion.setIntentVector(intentVectorJson);
//
//                    // pointVector 임베딩 후 저장
//                    float[] pointVector = embeddingService.embed(request.getQuestionText()+" "+ request.getPointText());
//                    String pointVectorJson = gson.toJson(pointVector);
//                    newQuestion.setPointVector(pointVectorJson);
                      questionRepository.save(newQuestion);
//                }
        }
        return new QuestionResponse.FindById(newQuestion);
    }

    // Admin - 질문 수정 기능
    @Transactional
    public QuestionResponse.FindById updateQuestion (QuestionRequest.UpdateQuestion request){
        InterviewQuestion newQuestion = questionRepository.findById(request.getQuestionId())
                .orElseThrow(() -> new AdminException404("해당 질문을 찾을 수 없습니다"));

        Admin newAdmin = adminRepository.findById(request.getAdminId())
                .orElseThrow(() -> new AdminException404("해당 관리자를 찾을 수 없습니다"));

        InterviewCategory newCategory = interviewCategoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new AdminException404("해당 카테고리를 찾을 수 없습니다"));

        boolean intentChanged = isTextChanged(
                newQuestion.getIntentText(),
                request.getIntentText()
        );
        boolean pointChanged = isTextChanged(
                newQuestion.getPointText(),
                request.getPointText()
        );
        boolean answerChanged = isTextChanged(
                newQuestion.getAnswerText(),
                request.getAnswerText()
        );


        // 바뀐 값으로 수정
        newQuestion.setQuestionText(request.getQuestionText());
        newQuestion.setInterviewLevel(request.getInterviewLevel());
        newQuestion.setAdminId(newAdmin);
        newQuestion.setCategoryId(newCategory);

        // Level1 이고 입력값이 바뀌었을 때
        if (request.getInterviewLevel() == InterviewLevel.LEVEL_1 && answerChanged) {
            newQuestion.setAnswerText(request.getAnswerText());
            float[] answerVector = embeddingService.embed(request.getAnswerText());
            newQuestion.setAnswerVector(gson.toJson(answerVector));
        } else if (request.getInterviewLevel() != InterviewLevel.LEVEL_1) { // Level이 1이 아닐 때
            newQuestion.setIntentText(request.getIntentText());
            newQuestion.setPointText(request.getPointText());

            // 값들이 바뀌었을 때만 다시 임베딩
//            if (intentChanged) {
//                float[] intentVector = embeddingService.embed(request.getIntentText());
//                newQuestion.setIntentVector(gson.toJson(intentVector));
//            }
//            if (pointChanged) {
//                float[] pointVector = embeddingService.embed(request.getPointText());
//                newQuestion.setPointVector(gson.toJson(pointVector));
//            }
        }

        questionRepository.save(newQuestion);
        return new QuestionResponse.FindById(newQuestion);
    }


    @Transactional
    public void deleteQuestion(Long questionId){

        // delete는 조회 없어도 오류 안떠서 question 조회 생략
        // admin 인지 확인하는 절차 추후 추가??
        questionRepository.deleteById(questionId);
    }


    // 기존 값과 같으면 false, 다르면 true 반환
    private boolean isTextChanged(String oldText, String newText){
        if(oldText == null && newText == null) return false;
        if(oldText == null || newText == null) return true;
        // 공백, 탭, 줄바꿈 제거 후 비교
        String normalizedOld = oldText.replaceAll("\\s+", ""); // `\s+` 모든 공백 제거 정규식
        String normalizedNew = newText.replaceAll("\\s+", "");
        return !normalizedOld.equals(normalizedNew);
    }
}
