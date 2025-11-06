package com.coach.chiselbot.domain.kakao;

import lombok.Getter;

@Getter
public class RedirectRequiredException extends RuntimeException {
  private final String redirectUrl;

  public RedirectRequiredException(String redirectUrl) {
    this.redirectUrl = redirectUrl;
  }
}
