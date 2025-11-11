package com.coach.chiselbot.domain.user;

import com.coach.chiselbot.domain.emailverification.EmailVerificationService;
import com.coach.chiselbot.domain.user.dto.UserRequestDTO;
import com.coach.chiselbot.domain.user.login.LoginStrategy;
import com.coach.chiselbot.domain.user.login.LoginStrategyFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
@Transactional
@RequiredArgsConstructor
public class UserService {

    private final UserJpaRepository userJpaRepository;
    private final PasswordEncoder passwordEncoder;
    private final LoginStrategyFactory loginStrategyFactory;
    private final EmailVerificationService emailVerificationService;

    @Value("${app.auth.require-email-verification}")
    private boolean requireEmailVerification;

    /**
     * 회원가입 처리
     */
    public User signUp(UserRequestDTO.SignUp dto) {

        String email = dto.getEmail().trim().toLowerCase();


        if (userJpaRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("이미 가입된 이메일입니다.");
        }

        if (requireEmailVerification) {
            boolean verified = emailVerificationService.isRecentlyVerified(email);
            if (!verified) {
                throw new IllegalArgumentException("이메일 인증이 필요합니다.");
            }
        }


        String encodedPassword = passwordEncoder.encode(dto.getPassword());
        User newUser = new User();
        newUser.setName(dto.getName());
        newUser.setEmail(email);
        newUser.setPassword(encodedPassword);

        return userJpaRepository.save(newUser);
    }

    /**
     * 로그인 처리
     */
    @Transactional(readOnly = true)
    public User login(String type, UserRequestDTO.Login dto) {

        LoginStrategy strategy = loginStrategyFactory.findStrategy(type);

        return strategy.login(dto);

    }

    /**
     * 회원 정보 수정 처리
     */
	public User update(String userEmail, UserRequestDTO.Update dto) {
		User user = userJpaRepository.findByEmail(userEmail)
				.orElseThrow(() -> new IllegalArgumentException("존재하지 않는 회원입니다."));

		if (user.getProvider() == Provider.KAKAO) {
			user.setName(dto.getName());
		} else  {
			user.setName(dto.getName());
			user.setPassword(passwordEncoder.encode(dto.getPassword()));
		}
		return userJpaRepository.save(user);
	}

    // 회원 전체 조회

    /**
     * 회원 단건 조회 처리
     */
    @Transactional(readOnly = true)
    public Map<String,Object> findOne(String userEmail) {
        User user = userJpaRepository.findByEmail(userEmail)
                .orElseThrow(() -> new IllegalArgumentException("회원이 아닙니다"));

        return Map.of(
                "id", user.getId(),
                "name", user.getName(),
                "email", user.getEmail()
        );
    }

	/**
	 * 이름으로 이메일 찾기 (마스킹)
	 */
	@Transactional(readOnly = true)
	public String findEmailByName(String name) {
		User user = userJpaRepository.findByName(name)
				.orElseThrow(() -> new IllegalArgumentException("해당 이름의 회원이 없습니다."));

		return maskEmail(user.getEmail());
	}

	/**
	 * 비밀번호 찾기용 인증번호 발송
	 */
	public void sendPasswordResetEmail(String email) {
		String normalizedEmail = email.trim().toLowerCase();

		User user = userJpaRepository.findByEmail(normalizedEmail)
				.orElseThrow(() -> new IllegalArgumentException("존재하지 않는 회원입니다."));

		emailVerificationService.sendCode(normalizedEmail);
	}


	/**
	 * 비밀번호 재설정
	 */
	public void resetPassword(UserRequestDTO.ResetPassword dto) {
		String email = dto.getEmail().trim().toLowerCase();

		// 이메일 인증 확인
		if (requireEmailVerification) {
			boolean verified = emailVerificationService.isRecentlyVerified(email);
			if (!verified) {
				throw new IllegalArgumentException("이메일 인증이 필요합니다.");
			}
		}

		User user = userJpaRepository.findByEmail(email)
				.orElseThrow(() -> new IllegalArgumentException("존재하지 않는 회원입니다."));

		user.setPassword(passwordEncoder.encode(dto.getNewPassword()));
		userJpaRepository.save(user);
	}

	/**
	 * 이메일 마스킹 처리
	 */
	private String maskEmail(String email) {
		String[] parts = email.split("@");
		String localPart = parts[0];
		String domain = parts[1];

		int visibleLength = Math.min(3, localPart.length());
		String visible = localPart.substring(0, visibleLength);
		String masked = visible + "***@" + domain;

		return masked;
	}

}
