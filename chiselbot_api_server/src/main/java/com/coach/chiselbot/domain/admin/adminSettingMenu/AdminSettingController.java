package com.coach.chiselbot.domain.admin.adminSettingMenu;

import com.coach.chiselbot._global.common.Define;
import com.coach.chiselbot.domain.admin.dto.AdminRequestDto;
import com.coach.chiselbot.domain.admin.dto.AdminResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/settings")
@RequiredArgsConstructor
public class AdminSettingController {

    private final AdminSettingService adminSettingService;

    @GetMapping
    public String adminSettingList(@RequestParam(defaultValue = "1") int page,
                                   @RequestParam(defaultValue = "10") int size,
                                   Model model) {

        Pageable pageable = PageRequest.of(page - 1, size, Sort.by(Sort.Direction.DESC, "id"));

        Page<AdminResponseDto.FindAll> adminPage = adminSettingService.getAdminList(pageable);

        int totalPages = adminPage.getTotalPages();
        List<Map<String, Object>> pageInfos = new ArrayList<>();

        for (int i = 1; i <= totalPages; i++) {
            Map<String, Object> info = new HashMap<>();
            info.put("index", i);
            info.put("number", i);
            info.put("current", i == page);
            pageInfos.add(info);
        }

        model.addAttribute("adminPage", adminPage);
        model.addAttribute("totalElements", adminPage.getTotalElements());
        model.addAttribute("hasPrevious", adminPage.hasPrevious());
        model.addAttribute("hasNext", adminPage.hasNext());
        model.addAttribute("prevPage", page - 1);
        model.addAttribute("nextPage", page + 1);
        model.addAttribute("pageInfos", pageInfos);

        return "adminSetting/adminSetting_list";
    }

    @PostMapping("/create")
    public String adminCreate(AdminRequestDto.adminCreate request,
                              RedirectAttributes rttr){
        adminSettingService.createAdmin(request);
        rttr.addFlashAttribute("message", Define.SUCCESS);
        return "redirect:/admin/settings";
    }

    @GetMapping("/create")
    public String adminCreateForm(){
        return "adminSetting/adminSetting_create";
    }

    @GetMapping("/delete/{id}")
    public String adminDelete(@PathVariable(name = "id") Long id,
                              RedirectAttributes rttr){
        adminSettingService.deleteAdmin(id);
        rttr.addFlashAttribute("message", Define.SUCCESS);
        return "redirect:/admin/settings";
    }

    @GetMapping("/api/{id}")
    @ResponseBody
    public AdminResponseDto.FindById adminDetailJson(@PathVariable(name = "id") Long id) {
        return adminSettingService.getDetail(id);
    }

    @DeleteMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<?> deleteAdmin(@PathVariable(name = "id") Long id) {
        adminSettingService.deleteAdmin(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/check-email")
    @ResponseBody
    public ResponseEntity<Boolean> checkEmail(@RequestParam String email) {
        boolean exists = adminSettingService.checkEmail(email);
        return ResponseEntity.ok(exists);
    }
}
