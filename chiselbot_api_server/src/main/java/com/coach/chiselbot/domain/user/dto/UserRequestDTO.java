package com.coach.chiselbot.domain.user.dto;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

public class UserRequestDTO {

    @Getter
    @Setter
    public static class SignUp {

        @NotEmpty
        @Size(min = 2, max = 20)
        private String name;

        @NotEmpty
        @Email
        @Pattern(regexp = "^[_a-z0-9-]+(.[_a-z0-9-]+)*@(?:\\w+\\.)+\\w+$", message = "유효한 이메일 형식이 아닙니다.")
        private String email;

        @NotEmpty
        @Size(min = 4, max = 20)
        private String password;

        private LocalDateTime createdAt;
    }

    @Getter
    @Setter
    public static class Login{
        @Email
        @Pattern(regexp = "^[_a-z0-9-]+(.[_a-z0-9-]+)*@(?:\\w+\\.)+\\w+$", message = "유효한 이메일 형식이 아닙니다.")
        private String email;
        private String password;
        private String authCode;
		private String accessToken;
    }

    @Getter
    @Setter
    public static class Update {

        private String email;

        @NotBlank
        @Size(min = 2, max = 20)
        private String name;

        @NotBlank
        @Size(min = 4, max = 20, message = "비밀번호는 4자 이상 필수입니다")
        private String password;

        private LocalDateTime updatedAt;
    }

	@Getter
	@Setter
	public static class FindEmail {
		@NotBlank
		@Size(min = 2, max = 20)
		private String name;
	}

	@Getter
	public static class FindPassword {
		@NotBlank
		@Email
		private String email;
	}


	@Getter
	@Setter
	public static class ResetPassword {
		@NotEmpty
		@Email
		private String email;

		@NotEmpty
		@Size(min = 4, max = 20)
		private String newPassword;
	}

}