package com.coach.chiselbot.domain.user;

import com.coach.chiselbot._global.config.jwt.JwtTokenProvider;
import com.coach.chiselbot._global.dto.CommonResponseDto;
import com.coach.chiselbot.domain.user.dto.UserRequestDTO;
import com.coach.chiselbot.domain.user.dto.UserResponseDTO;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RequestMapping("/api/users")
@RestController
@RequiredArgsConstructor
public class UserRestController {

    private final UserService userService;
    private final JwtTokenProvider jwtTokenProvider;

    /**
     * 회원가입 API
     * POST/api/users/signup
     */
    @PostMapping("/signup")
    public ResponseEntity<CommonResponseDto<?>> signup(@Valid @RequestBody UserRequestDTO.SignUp dto) {

        userService.signUp(dto);
        return ResponseEntity.ok(CommonResponseDto.success(null, "회원가입이 완료되었습니다"));
    }

    /**
     * 로그인 API
     * POST/api/users/login/{type}
     */
    @PostMapping("/login/{type}")
    public ResponseEntity<CommonResponseDto<?>> login(@PathVariable String type,
                                                      @Valid @RequestBody UserRequestDTO.Login dto) {
        User user = userService.login(type, dto);

        String token = jwtTokenProvider.createToken(user);

        UserResponseDTO response = UserResponseDTO.builder()
                .userId(String.valueOf(user.getId())) // User 엔티티의 ID 사용
                .name(user.getName()) // User 엔티티의 Name 사용
                .token(token)
                .build();

        return ResponseEntity.ok(CommonResponseDto.success(response, "로그인에 성공했습니다"));
    }

    /**
     * 회원정보 수정 API
     * Patch/api/users/update
     */
    @PatchMapping("/update")
    public ResponseEntity<CommonResponseDto<?>> updateMe(
            @RequestAttribute("userEmail") String userEmail,
            @Valid @RequestBody UserRequestDTO.Update dto
    ) {
        userService.update(userEmail, dto);
        return ResponseEntity.ok(CommonResponseDto.success(null, "수정되었습니다."));
    }

    /**
     * 로그아웃 API
     * POST/api/users/api
     */
    @PostMapping("/logout")
    public ResponseEntity<?> logout() {
        return ResponseEntity.ok(CommonResponseDto.success(null, "로그아웃 되었습니다"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CommonResponseDto<?>> findOne(@PathVariable String userEmail) {
        return ResponseEntity.ok(CommonResponseDto.success(userService.findOne(userEmail), "조회되었습니다."));
    }

	/**
	 * 내 정보 조회 API (JWT 기반)
	 * GET /api/users/me
	 */
	@GetMapping("/me")
	public ResponseEntity<CommonResponseDto<?>> getMyProfile(
			@RequestAttribute("userEmail") String userEmail
	) {
		Map<String, Object> user = userService.findOne(userEmail);
		return ResponseEntity.ok(CommonResponseDto.success(user, "조회되었습니다."));
	}

}