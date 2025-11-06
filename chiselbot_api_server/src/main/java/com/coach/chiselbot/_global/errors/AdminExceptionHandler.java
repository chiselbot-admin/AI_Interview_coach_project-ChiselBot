package com.coach.chiselbot._global.errors;

import com.coach.chiselbot._global.errors.adminException.*;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@Slf4j
@Order(1)
@ControllerAdvice(annotations = Controller.class)
public class AdminExceptionHandler {

    @ExceptionHandler
    public String ex400(AdminException400 e, HttpServletRequest request) {
        log.warn("=== 400 Bad Request 에러 발생 ===");
        log.warn("요청 URL : {}", request.getRequestURL());
        log.warn("인증 오류: {}", e.getMessage());
        log.warn("User-Agent: {}", request.getHeader("User-Agent"));
        request.setAttribute("msg", e.getMessage());
        return "error/400";
    }

//    @ExceptionHandler(Exception401.class)
//    public String ex401(Exception401 e, HttpServletRequest request) {
//        log.warn("=== 401 UnAuthorized 에러 발생 ===");
//        log.warn("요청 URL : {}", request.getRequestURL());
//        log.warn("인증 오류: {}", e.getMessage());
//        log.warn("User-Agent: {}", request.getHeader("User-Agent"));
//        request.setAttribute("msg", e.getMessage());
//        return "err/401";
//    }

	@ExceptionHandler(AdminException401.class)
	public String ex401ByData(AdminException401 e, HttpServletRequest request) {
		log.warn("=== 401 UnAuthorized 에러 발생 ===");
		log.warn("요청 URL : {}", request.getRequestURL());
		log.warn("인증 오류: {}", e.getMessage());
		log.warn("User-Agent: {}", request.getHeader("User-Agent"));
		request.setAttribute("msg", e.getMessage());
		return "redirect:/login-form";
	}



    @ExceptionHandler(AdminException403.class)
    public String ex403(AdminException403 e, HttpServletRequest request) {

        log.warn("=== 403 Forbidden 에러 발생 ===");
        log.warn("요청 URL : {}", request.getRequestURL());
        log.warn("인증 오류: {}", e.getMessage());
        log.warn("User-Agent: {}", request.getHeader("User-Agent"));

        request.setAttribute("msg", e.getMessage());
        return "error/403";
    }

    @ExceptionHandler(AdminException404.class)
    public String ex404(AdminException404 e, HttpServletRequest request) {
        log.warn("=== 404 Not Found 에러 발생 ===");
        System.out.println("=== 404 예외 핸들러 진입 1===");
        log.warn("요청 URL : {}", request.getRequestURL());
        log.warn("인증 오류: {}", e.getMessage());
        log.warn("User-Agent: {}", request.getHeader("User-Agent"));
        request.setAttribute("msg", e.getMessage());
        return "error/404";
    }

    @ExceptionHandler(AdminException500.class)
    public String ex401(AdminException500 e, HttpServletRequest request) {
        log.warn("=== 500 Internal Server Error 에러 발생 ===");
        log.warn("요청 URL : {}", request.getRequestURL());
        log.warn("인증 오류: {}", e.getMessage());
        log.warn("User-Agent: {}", request.getHeader("User-Agent"));
        request.setAttribute("msg", e.getMessage());
        return "error/500";
    }

    // 기타 모든 RuntimeException 처리
    @ExceptionHandler(RuntimeException.class)
    public String handleRuntimeException(RuntimeException e, HttpServletRequest request) {
        log.warn("=== 예상 못한 런타임 에러 발생 ===");
        log.warn("요청 URL : {}", request.getRequestURL());
        log.warn("인증 오류: {}", e.getMessage());
        log.warn("User-Agent: {}", request.getHeader("User-Agent"));
        request.setAttribute("msg", "시스템 오류 발생, 관리자에게 문의 하세요");
        return "error/500";
    }
}