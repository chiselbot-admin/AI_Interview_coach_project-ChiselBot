package com.coach.chiselbot.domain.userStorage;

import com.coach.chiselbot.domain.interview_question.InterviewQuestion;
import com.coach.chiselbot.domain.interview_question.InterviewQuestionRepository;
import com.coach.chiselbot.domain.user.User;
import com.coach.chiselbot.domain.user.UserJpaRepository;
import com.coach.chiselbot.domain.userStorage.dto.StorageRequest;
import com.coach.chiselbot.domain.userStorage.dto.StorageResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
public class UserStorageService {

    private final UserStorageRepository storageRepository;
    private final UserJpaRepository userRepository;
    private final InterviewQuestionRepository interviewQuestionRepository;

    @Transactional
    public StorageResponse.FindById saveStorage(StorageRequest.SaveRequest request, String userEmail){
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("해당 유저를 찾을 수 없습니다"));

        InterviewQuestion question = interviewQuestionRepository.findById(request.getQuestionId())
                .orElseThrow(() -> new NoSuchElementException("해당 질문을 찾을 수 없습니다"));

        UserStorage newStorage = new UserStorage();
        newStorage.setUser(user);
        newStorage.setQuestion(question);
        newStorage.setFeedback(request.getFeedback());
        newStorage.setHint(request.getHint());
        newStorage.setUserAnswer(request.getUserAnswer());
        newStorage.setSimilarity(request.getSimilarity());
        newStorage.setGrade(request.getGrade());
        storageRepository.save(newStorage);

        return new StorageResponse.FindById(newStorage);
    }

    @Transactional
    public void deleteStorage(Long storageId, String userEmail){
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("해당 유저를 찾을 수 없습니다"));

        UserStorage storage = storageRepository.findById(storageId)
                .orElseThrow(() -> new RuntimeException("보관함 데이터를 찾을 수 없습니다"));

        if(!storage.getUser().getId().equals(user.getId())){
            throw new SecurityException("본인 보관함만 삭제 할 수 있습니다");
        }

        storageRepository.delete(storage);
    }

    @Transactional(readOnly = true)
    public List<StorageResponse.FindAll> getStorageList(String userEmail){
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("해당 유저를 찾을 수 없습니다"));

        // 최신순 조회(CreatedAt 기준)
        List<UserStorage> storageList = storageRepository.findByUserOrderByCreatedAtDesc(user);

        return StorageResponse.FindAll.from(storageList);
    }

    @Transactional(readOnly = true)
    public StorageResponse.FindById getStorageDetail(Long storageId, String userEmail){
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("해당 유저를 찾을 수 없습니다"));

        UserStorage storage =  storageRepository.findById(storageId)
                .orElseThrow(() -> new NoSuchElementException("보관함 데이터를 찾을 수 없습니다"));

        return new StorageResponse.FindById(storage);
    }

}
