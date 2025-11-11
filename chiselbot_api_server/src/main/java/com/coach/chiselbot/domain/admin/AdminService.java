package com.coach.chiselbot.domain.admin;

import com.coach.chiselbot._global.common.Define;
import com.coach.chiselbot._global.errors.adminException.AdminException400;
import com.coach.chiselbot._global.errors.adminException.AdminException404;
import com.coach.chiselbot.domain.admin.dto.AdminRequestDto;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminService {

    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;

    /**
     * 로그인 처리
     */
    @Transactional(readOnly = true)
    public Admin login(AdminRequestDto.Login request) {

        Admin admin = adminRepository.findByEmail(request.getEmail()).orElseThrow(
                () -> new AdminException404(Define.EMAIL_NOT_FOUND));

        if (!passwordEncoder.matches(request.getPassword(), admin.getPassword())) {
            throw new AdminException400(Define.PASSWORD_MISMATCH);
        }
        return admin;
    }

    /**
     * 로그아웃 처리
     */
    public void logout(HttpSession session) {
        if (session != null) {
            session.invalidate();
        }
    }
}
