package com.coach.chiselbot.domain.interview_coach.prompt;

import com.coach.chiselbot._global.errors.adminException.AdminException500;
import com.coach.chiselbot.domain.interview_coach.prompt.dto.PromptRequest;
import com.coach.chiselbot.domain.interview_coach.prompt.dto.PromptResponse;
import com.coach.chiselbot.domain.interview_question.InterviewLevel;
import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PromptService {
    private final PromptRepository promptRepository;
    private final EntityManager em;

    /**
     * 새 프롬프트 등록
     * */
    @Transactional
    public PromptResponse.FindById registerPrompt(PromptRequest.CreatePrompt request) {
        // 현재 레벨의 프롬프트 개수 조회(버전 따로 관리)
        long count = promptRepository.countByLevel(request.getLevel());

        // 새로운 프롬프트 생성
        Prompt prompt = new Prompt();
        prompt.setLevel(request.getLevel());
        prompt.setPromptBody(request.getPromptBody());
        prompt.setVersionName("v" + (count + 1));
        prompt.setIsActive(request.getIsActive());

        promptRepository.save(prompt);

        // NULL 방지
        if (Boolean.TRUE.equals(request.getIsActive())) {
            List<Prompt> existingPrompts = promptRepository.findByLevel(request.getLevel());
            for (Prompt p : existingPrompts) {
                if (!p.getId().equals(prompt.getId())) {
                    p.setIsActive(false);
                }
            }
            promptRepository.saveAll(existingPrompts);
        }

        return new PromptResponse.FindById(prompt);
    }

    /**
     * 기존 프롬프트 수정
     */
    @Transactional
    public PromptResponse.FindById updatePrompt(Long id, String newBody, Boolean newActive) {
        Prompt prompt = promptRepository.findById(id)
                .orElseThrow(() -> new AdminException500("해당 프롬프트가 없습니다."));

        if (newBody != null) prompt.setPromptBody(newBody);


        // 활성화 시키면 같은레벨의 나머지 버전 프롬프트 비활성화
        if (newActive != null && newActive) {
            List<Prompt> prompts = promptRepository.findByLevel(prompt.getLevel());
            prompts.forEach(p -> p.setIsActive(false));
            promptRepository.saveAll(prompts);
            prompt.setIsActive(true);
        } else if (newActive != null) {
            prompt.setIsActive(false);
        }
        promptRepository.save(prompt);

        return new PromptResponse.FindById(prompt);
    }

    // 레벨별 활성화된 프롬프트 목록
    // 레벨마다 활성화된 프롬프트를 찾고, 존재하는 것만 리스트로 만들어 반환
    public List<PromptResponse.FindById> getActivePrompts() {
        List<PromptResponse.FindById> result = new ArrayList<>();

        for (InterviewLevel level : InterviewLevel.values()) {
            Prompt prompt = promptRepository
                    .findFirstByLevelAndIsActiveTrue(level)
                    .orElse(null);

            if (prompt != null) {
                result.add(new PromptResponse.FindById(prompt));
            } else {
                Prompt empty = new Prompt();
                empty.setLevel(level);
                empty.setId(null);
                empty.setVersionName("-");
                empty.setIsActive(false);
                empty.setPromptBody("활성화된 프롬프트 없음");
                result.add(new PromptResponse.FindById(empty));
            }
        }

        return result;
    }

    // 레벨별 프롬프트 목록 조회
    public List<PromptResponse.FindAll> getPromptsByLevel(InterviewLevel level) {
        List<Prompt> prompts = promptRepository.findByLevelOrderByIdDesc(level);
        return PromptResponse.FindAll.from(prompts);
    }


    // 프롬프트 상세조회
    public PromptResponse.FindById getPromptById(Long id) {
        Prompt prompt = promptRepository.findById(id)
                .orElseThrow(() -> new AdminException500("해당 프롬프트가 없습니다."));
        return new PromptResponse.FindById(prompt);
    }


}
