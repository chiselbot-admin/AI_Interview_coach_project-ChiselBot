package com.coach.chiselbot.domain.admin;

import com.coach.chiselbot._global.common.Define;
import com.coach.chiselbot.domain.admin.dto.AdminRequestDto;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    /**
     * 관리자 로그인 화면 연결 API
     * GET/login-form
     */
    @GetMapping("/login-form")
    public String loginForm() {
        return "auth/login";
    }

    /**
     * 관리자 로그인 API
     * GET/login
     */
    @PostMapping("/login")
    public String login(AdminRequestDto.Login request, HttpSession session) {
        Admin admin = adminService.login(request);
        session.setAttribute(Define.SESSION_USER, admin);
        return "redirect:/";
    }

    /**
     * 관리자 로그아웃 API
     * GET/logout
     */
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        adminService.logout(session);
        return "redirect:/login-form";
    }
}
