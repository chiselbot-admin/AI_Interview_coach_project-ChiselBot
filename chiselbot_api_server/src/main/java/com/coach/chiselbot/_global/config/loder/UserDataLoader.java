package com.coach.chiselbot._global.config.loder;

import com.coach.chiselbot.domain.user.Provider;
import com.coach.chiselbot.domain.user.User;
import com.coach.chiselbot.domain.user.UserJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Profile("local")
@Order(1)
public class UserDataLoader implements CommandLineRunner {

    private final UserJpaRepository userJpaRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {

        User testUser1 = userJpaRepository.save(new User(
                null,
                "유저1",
                "test1@naver.com",
                passwordEncoder.encode("1234")
                , Provider.LOCAL));

        User testUser2 = userJpaRepository.save(new User(
                null,
                "유저2",
                "test2@naver.com",
                passwordEncoder.encode("1234")
                , Provider.LOCAL));


        User testUser3 = userJpaRepository.save(new User(
                        null,
                        "유저3",
                        "test3@naver.com",
                        passwordEncoder.encode("1234")
                        , Provider.LOCAL
                )
        );
    }
}
