package com.coach.chiselbot.domain.interview_coach.prompt;

import com.coach.chiselbot._global.common.Define;
import com.coach.chiselbot.domain.interview_coach.prompt.dto.PromptRequest;
import com.coach.chiselbot.domain.interview_coach.prompt.dto.PromptResponse;
import com.coach.chiselbot.domain.interview_question.InterviewLevel;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/prompts")
public class PromptController {

    private final PromptService promptService;

    @GetMapping
    public String promptIndex(Model model) {
        model.addAttribute("activePrompts", promptService.getActivePrompts());
        return "promptManager/prompt_index";
    }

    /** 레벨별 버전 목록 화면 */
    @GetMapping("/list")
    public String promptList(@RequestParam InterviewLevel level, Model model) {
        List<PromptResponse.FindAll> prompts = promptService.getPromptsByLevel(level);
        model.addAttribute("prompts", prompts);
        model.addAttribute("level", level);
        return "promptManager/prompt_list";
    }

    /** 프롬프트 상세보기 + 수정 폼 */
    @GetMapping("/detail/{id}")
    public String promptDetail(@PathVariable Long id,
                               Model model) {
        PromptResponse.FindById prompt = promptService.getPromptById(id);
        model.addAttribute("prompt", prompt);
        return "promptManager/prompt_detail";
    }

    /** 수정 처리 */
    @PostMapping("/detail/{id}")
    public String updatePrompt(@PathVariable Long id,
                               @RequestParam(required = false) String promptBody,
                               @RequestParam(defaultValue = "false")Boolean activate,
                               RedirectAttributes rttr) {
        PromptResponse.FindById result = promptService.updatePrompt(id, promptBody, activate);

        rttr.addFlashAttribute("message", Define.SUCCESS);

        return "redirect:/admin/prompts/list?level="+result.getLevel();
    }

    /** AJAX 토글 */
    @PostMapping("/toggle/{id}")
    @ResponseBody
    public String toggleActive(@PathVariable Long id, @RequestParam boolean active) {
        promptService.updatePrompt(id, null, active);
        return "OK";
    }

    @PostMapping("/create")
    public String createPrompt(@ModelAttribute("promptForm") PromptRequest.CreatePrompt request,
                               RedirectAttributes rttr) {

        System.out.println("isActive: " + request.getIsActive());
        PromptResponse.FindById result = promptService.registerPrompt(request);

        rttr.addFlashAttribute("message", "프롬프트가 성공적으로 등록되었습니다.");

        return "redirect:/admin/prompts/list?level=" + result.getLevel();
    }

    @GetMapping("/create")
    public String createPromptForm(Model model) {

        model.addAttribute("levels", InterviewLevel.values());
        model.addAttribute("promptForm", new PromptRequest.CreatePrompt());
        return "promptManager/prompt_create";
    }
}
