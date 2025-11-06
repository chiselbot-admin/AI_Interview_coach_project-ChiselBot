package com.coach.chiselbot._global.errors;

import com.coach.chiselbot._global.dto.CommonResponseDto;
import com.coach.chiselbot._global.errors.exception.Exception400;
import com.coach.chiselbot._global.errors.exception.*;
import com.coach.chiselbot.domain.kakao.RedirectRequiredException;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.net.URI;

@Order(0)
@RestControllerAdvice(annotations = RestController.class)
public class ApiExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(ApiExceptionHandler.class);

    @ExceptionHandler(RedirectRequiredException.class)
    public ResponseEntity<Void> handleRedirect(RedirectRequiredException e) {
        HttpHeaders headers = new HttpHeaders();
        headers.setLocation(URI.create(e.getRedirectUrl()));
        return new ResponseEntity<>(headers, HttpStatus.FOUND);
    }

    @ExceptionHandler(Exception400.class)
    public ResponseEntity<?> ex400(Exception400 e, HttpServletRequest request) {
        log.warn("=== 400 Bad Request 에러 발생 ===");
        log.warn("요청 URL : {}", request.getRequestURL());
        log.warn("인증 오류: {}", e.getMessage());
        log.warn("User-Agent: {}", request.getHeader("User-Agent"));

        return new ResponseEntity<>(
                CommonResponseDto.error(e.getMessage()),
                HttpStatus.BAD_REQUEST
        );
    }

    @ExceptionHandler(Exception401.class)
    public ResponseEntity<?> ex401(Exception401 e, HttpServletRequest request) {
        log.warn("=== 401 UnAuthorized 에러 발생 ===");
        log.warn("요청 URL : {}", request.getRequestURL());
        log.warn("인증 오류: {}", e.getMessage());
        log.warn("User-Agent: {}", request.getHeader("User-Agent"));

        return new ResponseEntity<>(
                CommonResponseDto.error(e.getMessage()),
                HttpStatus.UNAUTHORIZED
        );
    }



    @ExceptionHandler(Exception403.class)
    public ResponseEntity<?> ex403(Exception403 e, HttpServletRequest request) {
        log.warn("=== 403 Forbidden 에러 발생 ===");
        log.warn("요청 URL : {}", request.getRequestURL());
        log.warn("인증 오류: {}", e.getMessage());
        log.warn("User-Agent: {}", request.getHeader("User-Agent"));
        return new ResponseEntity<>(
                CommonResponseDto.error(e.getMessage()),
                HttpStatus.FORBIDDEN
        );
    }

    @ExceptionHandler(Exception404.class)
    public ResponseEntity<?> ex404(Exception404 e, HttpServletRequest request) {
        log.warn("=== 404 Not Found 에러 발생 ===");
        log.warn("요청 URL : {}", request.getRequestURL());
        log.warn("인증 오류: {}", e.getMessage());
        log.warn("User-Agent: {}", request.getHeader("User-Agent"));
        return new ResponseEntity<>(
                CommonResponseDto.error(e.getMessage()),
                HttpStatus.NOT_FOUND
        );
    }

    @ExceptionHandler(Exception500.class)
    public ResponseEntity ex500(Exception500 e, HttpServletRequest request) {
        log.warn("=== 500 Internal Server Error 에러 발생 ===");
        log.warn("요청 URL : {}", request.getRequestURL());
        log.warn("인증 오류: {}", e.getMessage());
        log.warn("User-Agent: {}", request.getHeader("User-Agent"));

        return new ResponseEntity<>(
                CommonResponseDto.error(e.getMessage()),
                HttpStatus.UNAUTHORIZED
        );
    }

    // 기타 모든 RuntimeException 처리
    @ExceptionHandler(RuntimeException.class)
    public ResponseEntity<?> handleRuntimeException(RuntimeException e, HttpServletRequest request) {
        log.warn("=== 예상 못한 런타임 에러 발생 ===");
        log.warn("요청 URL : {}", request.getRequestURL());
        log.warn("인증 오류: {}", e.getMessage());
        log.warn("User-Agent: {}", request.getHeader("User-Agent"));
        return new ResponseEntity<>(
                CommonResponseDto.error(e.getMessage()),
                HttpStatus.UNAUTHORIZED
        );
    }

}
