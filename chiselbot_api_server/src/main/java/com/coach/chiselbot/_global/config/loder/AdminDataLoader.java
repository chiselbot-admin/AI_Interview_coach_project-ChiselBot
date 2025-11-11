package com.coach.chiselbot._global.config.loder;

import com.coach.chiselbot.domain.admin.Admin;
import com.coach.chiselbot.domain.admin.AdminRepository;
import com.coach.chiselbot.domain.interview_category.InterviewCategory;
import com.coach.chiselbot.domain.interview_category.InterviewCategoryRepository;
import com.coach.chiselbot.domain.interview_coach.prompt.Prompt;
import com.coach.chiselbot.domain.interview_coach.prompt.PromptRepository;
import com.coach.chiselbot.domain.interview_question.InterviewLevel;
import com.coach.chiselbot.domain.interview_question.InterviewQuestionRepository;
import com.coach.chiselbot.domain.interview_question.InterviewQuestionService;
import com.coach.chiselbot.domain.interview_question.dto.QuestionRequest;
import com.coach.chiselbot.domain.menuInfo.MenuInfo;
import com.coach.chiselbot.domain.menuInfo.MenuInfoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
@RequiredArgsConstructor
@Profile("local")
@Order(2)
public class AdminDataLoader implements CommandLineRunner {

    private final AdminRepository adminRepository;
    private final InterviewCategoryRepository categoryRepository;
    private final InterviewQuestionRepository questionRepository;
    private final MenuInfoRepository menuInfoRepository;
    private final PasswordEncoder passwordEncoder;
    private final PromptRepository promptRepository;

    // 서비스 주입
    private final InterviewQuestionService interviewQuestionService;

    @Override
    public void run(String... args) throws Exception {

        String password = passwordEncoder.encode("1234");

        if (adminRepository.count() == 0) {
            Admin admin = Admin.builder()
                    .adminName("관리자")
                    .email("admin@chisel.com")
                    .password(password)
                    .build();

            adminRepository.save(admin);
            System.out.println("기본 관리자 계정 생성 완료: admin@chisel.com");
        } else {
            System.out.println("Admin 데이터 이미 존재하므로 로드 생략");
        }


        // 1. 카테고리 먼저 저장 (이미 있으면 생략)
        InterviewCategory category = categoryRepository.findById(1L)
                .orElseGet(() -> {
                    InterviewCategory newCategory = new InterviewCategory(1L, "Java");
                    return categoryRepository.save(newCategory);
                });
        InterviewCategory category2 = categoryRepository.findById(2L)
                .orElseGet(() -> {
                    InterviewCategory newCategory = new InterviewCategory(2L, "Oracle");
                    return categoryRepository.save(newCategory);
                });
        InterviewCategory category3 = categoryRepository.findById(3L)
                .orElseGet(() -> {
                    InterviewCategory newCategory = new InterviewCategory(3L, "CSS");
                    return categoryRepository.save(newCategory);
                });
        Admin admin = adminRepository.findById(2L)
                .orElseGet(() -> {
                    Admin newAdmin = Admin.builder()
                            .adminName("관리자2")
                            .email("admin22@chisel.com")
                            .password("1234")
                            .build();
                    return adminRepository.save(newAdmin);
                });

//        // 2. InterviewQuestion 더미 데이터
//        InterviewQuestion question = new InterviewQuestion();
//        question.setCategoryId(category);
//        question.setInterviewLevel(InterviewLevel.LEVEL_1);
//        question.setAdminId(admin);
//        question.setQuestionText("JDBC는 무엇인가요");
//        question.setAnswerText("자바에서 DB에 접근하여 데이터를 조회, 삽입, 수정, 삭제할 수 있도록 자바와 DB를 연결해 주는 인터페이스");
//        question.setAnswerVector("[0.0123, -0.0345, 0.0567, -0.0789, 0.0912, -0.0456, 0.0678, -0.0123, 0.0345, -0.0567]");
//
//        // 3. 저장
//        questionRepository.save(question);

        // 2. InterviewQuestion 더미 데이터 (서비스를 통해 임베딩까지 저장)
        QuestionRequest.CreateQuestion req = new QuestionRequest.CreateQuestion();
        req.setCategoryId(category.getCategoryId());               // 1L (Java)
        req.setInterviewLevel(InterviewLevel.LEVEL_1);
        req.setAdminId(admin.getId());
        req.setQuestionText("JDBC는 무엇인가요?");
        req.setAnswerText("자바에서 DB에 접근하여 데이터를 조회, 삽입, 수정, 삭제할 수 있도록 자바와 DB를 연결해 주는 인터페이스");

        // 이미 같은 카테고리/레벨 질문이 없다면 하나 생성 (중복 방지 - 선택)
        if (questionRepository.findFirstByCategoryId_CategoryIdAndInterviewLevel(
                category.getCategoryId(), InterviewLevel.LEVEL_1).isEmpty()) {
            interviewQuestionService.createQuestion(req); // 임베딩(벡터) 생성/저장
        }

        // --- 메뉴 더미 데이터 추가 ---
        if (menuInfoRepository.count() == 0) {
            MenuInfo dashboard = menuInfoRepository.save(MenuInfo.builder()
                    .menuName("메뉴관리")
                    .menuCode("ADMIN_MENU_INFO")
                    .urlPath("/admin/menus")
                    .menuOrder(1)
                    .description("관리자 메뉴관리")
                    .build());

            MenuInfo questionMenu = menuInfoRepository.save(MenuInfo.builder()
                    .menuName("질문관리")
                    .menuCode("ADMIN_QUESTION")
                    .urlPath("/admin/questions")
                    .menuOrder(2)
                    .description("면접 질문 관리")
                    //.parent(dashboard) // 부모 연결 가능
                    .build());

            MenuInfo inquiryMenu = menuInfoRepository.save(MenuInfo.builder()
                    .menuName("1:1문의 관리")
                    .menuCode("ADMIN_INQUIRY")
                    .urlPath("/admin/inquiries")
                    .menuOrder(4)
                    .description("1:1 문의 관리 ")
                    //.parent(dashboard) // 부모 연결 가능
                    .build());

            MenuInfo noticeMenu = menuInfoRepository.save(MenuInfo.builder()
                    .menuName("공지사항 관리")
                    .menuCode("NOTICE")
                    .urlPath("/admin/notice")
                    .menuOrder(5)
                    .description("공지사항 관리")
                    //.parent(dashboard) // 부모 연결 가능
                    .build());
            MenuInfo promptMenu = menuInfoRepository.save(MenuInfo.builder()
                    .menuName("프롬프트 관리")
                    .menuCode("PROMPT")
                    .urlPath("/admin/prompts")
                    .menuOrder(3)
                    .description("프롬프트 관리")
                    //.parent(dashboard) // 부모 연결 가능
                    .build());
            MenuInfo adminMenu = menuInfoRepository.save(MenuInfo.builder()
                    .menuName("관리자 관리")
                    .menuCode("ADMIN")
                    .urlPath("/admin/settings")
                    .menuOrder(4)
                    .description("관리자 관리")
                    //.parent(dashboard) // 부모 연결 가능
                    .build());
        }

        // 프롬프트 더미
        List<Prompt> prompts = new ArrayList<>();
        Prompt prompt = new Prompt();
        prompt.setIsActive(true);
        prompt.setLevel(InterviewLevel.LEVEL_1);
        prompt.setVersionName("v1");
        prompt.setPromptBody("너는 기술 면접 코치이다.\n" +
                "        아래의 문제, 사용자의 답변, 코사인유사도 점수를 보고\n" +
                "        JSON 형식으로 간결한 피드백을 작성하라.\n" +
                "\n" +
                "        규칙:\n" +
                "        1. 출력은 반드시 JSON 형식으로 해야 한다.\n" +
                "        2. 항상 아래 다섯 개의 필드를 모두 포함하라:\n" +
                "            - \"feedback\": 사용자의 답변에 대한 간결한 한문장 평가\n" +
                "            - \"hint\": similarity < 0.8 일때만 작성, 엄청 짧은 한문장 힌트문구\n" +
                "            - \"userAnswer\": 내용은 비워둔다\n" +
                "            - \"questionId\": 내용은 비워둔다\n" +
                "            - \"similarity\": 입력받은 유사도 값 그대로 출력.\n" +
                "        3. 유사도(similarity)가 높을수록 칭찬 위주로, 낮을수록 보완점 위주로 작성한다.\n" +
                "        4. 불필요한 설명, JSON 밖의 문장은 절대 포함하지 마라.\n" +
                "        5. \"feedback\"과 \"hint\" 문장은 모두 **'~요'로 끝나는 해요체 말투**로 작성한다.\n" +
                "\n" +
                "        ---\n" +
                "        문제: %s\n" +
                "        사용자의 답변: %s\n" +
                "        코사인유사도: %.2f\n" +
                "        ---\n" +
                "        JSON:");
        prompts.add(prompt);
        Prompt prompt2 = new Prompt();
        prompt2.setIsActive(false);
        prompt2.setLevel(InterviewLevel.LEVEL_1);
        prompt2.setVersionName("v2");
        prompt2.setPromptBody("너는 기술 면접 코치이다.\n" +
                "        아래의 문제, 사용자의 답변, 코사인유사도 점수를 보고\n" +
                "        JSON 형식으로 간결한 피드백을 작성하라.\n" +
                "\n" +
                "        규칙:\n" +
                "        1. 출력은 반드시 JSON 형식으로 해야 한다.\n" +
                "        2. 항상 아래 다섯 개의 필드를 모두 포함하라:\n" +
                "            - \"feedback\": 사용자의 답변에 대한 간결한 한문장 평가\n" +
                "            - \"hint\": similarity < 0.8 일때만 작성, 엄청 짧은 한문장 힌트문구\n" +
                "            - \"userAnswer\": 내용은 비워둔다\n" +
                "            - \"questionId\": 내용은 비워둔다\n" +
                "            - \"similarity\": 입력받은 유사도 값 그대로 출력.\n" +
                "        3. 유사도(similarity)가 높을수록 칭찬 위주로, 낮을수록 보완점 위주로 작성한다.\n" +
                "        4. 불필요한 설명, JSON 밖의 문장은 절대 포함하지 마라.\n" +
                "        5. \"feedback\"과 \"hint\" 문장은 모두 **'~요'로 끝나는 해요체 말투**로 작성한다.\n" +
                "\n" +
                "        ---\n" +
                "        문제: %s\n" +
                "        사용자의 답변: %s\n" +
                "        코사인유사도: %.2f\n" +
                "        ---\n" +
                "        JSON:");
        prompts.add(prompt2);

        Prompt prompt3 = new Prompt();
        prompt3.setIsActive(true);
        prompt3.setLevel(InterviewLevel.LEVEL_2);
        prompt3.setVersionName("v1");
        prompt3.setPromptBody("너는 기술 면접 코치이다.  \n" +
                "아래의 문제, 질문 의도, 핵심 포인트, 사용자의 답변을 보고  \n" +
                "JSON 형식으로 간결한 피드백을 작성하라.  \n" +
                "\n" +
                "규칙:  \n" +
                "1. 출력은 반드시 JSON 형식으로 해야 한다.  \n" +
                "2. 항상 아래 여섯 개의 필드를 모두 포함하라:  \n" +
                "   - \"feedback\": 사용자의 답변 전반에 대한 한문장 평가  \n" +
                "   - \"hint\": 답변이 충분하지 않을 경우에만 작성 (짧은 한문장 조언)  \n" +
                "   - \"grade\": 답변의 전반적 완성도를 \"상\", \"중\", \"하\" 중 하나로 평가  \n" +
                "   - \"userAnswer\": 내용은 비워둔다  \n" +
                "   - \"questionId\": 내용은 비워둔다  \n" +
                "   - \"intentText\": 내용은 비워둔다  \n" +
                "   - \"pointText\": 내용은 비워둔다  \n" +
                "\n" +
                "3. \"grade\"의 기준은 다음과 같다:  \n" +
                "   - 상: 질문 의도와 핵심 포인트가 모두 잘 반영되어 답변이 정확하고 논리적일 때  \n" +
                "   - 중: 질문 의도는 이해했지만 핵심 포인트 일부가 빠졌거나 표현이 다소 모호할 때  \n" +
                "   - 하: 질문 의도나 핵심 포인트 중 하나라도 거의 반영되지 않았을 때  \n" +
                "\n" +
                "4. \"feedback\"과 \"hint\" 문장은 모두 **‘~요’로 끝나는 해요체 말투**로 작성한다.  \n" +
                "5. 불필요한 설명이나 JSON 밖의 문장은 절대 포함하지 마라.  \n" +
                "\n" +
                "---  \n" +
                "문제: %s  \n" +
                "질문 의도(intent): %s  \n" +
                "핵심 포인트(point): %s  \n" +
                "사용자의 답변: %s  \n" +
                "---  \n" +
                "JSON:");
        prompts.add(prompt3);
        promptRepository.saveAll(prompts);
    }
}
