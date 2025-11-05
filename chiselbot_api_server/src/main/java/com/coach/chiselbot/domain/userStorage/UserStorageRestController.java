package com.coach.chiselbot.domain.userStorage;

import com.coach.chiselbot._global.common.Define;
import com.coach.chiselbot._global.dto.CommonResponseDto;
import com.coach.chiselbot.domain.userStorage.dto.StorageRequest;
import com.coach.chiselbot.domain.userStorage.dto.StorageResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/storages")
@RequiredArgsConstructor
public class UserStorageRestController {

    private final UserStorageService storageService;

    /**
     * <p>AI 피드백 결과를 사용자의 보관함에 저장합니다.</p>
     *
     * <pre><code class="json">
     * 요청 예시:
     * {
     *   "userId": 1,                     // (테스트용) JWT 인증 시 실제로는 무시됨
     *   "questionId": 5,                 // 저장할 질문 ID
     *   "userAnswer": "TCP는 연결 기반의 프로토콜입니다.",
     *   "similarity": 0.82,              // AI 계산 유사도 (선택)
     *   "feedback": "핵심 개념은 맞지만, 신뢰성 언급이 빠졌습니다.",
     *   "hint": "TCP는 순서 보장과 재전송 기능을 제공합니다."
     * }
     * </code></pre>
     *
     * <pre><code class="json">
     * 응답 예시:
     * {
     *   "success": true,
     *   "data": {
     *     "storageId": 12,
     *     "questionId": 5,
     *     "questionText": "TCP는 무엇인가요?",
     *     "userAnswer": "TCP는 연결 기반의 프로토콜입니다.",
     *     "questionAnswer": "질문에 대한 답 (DB기반)",
     *     "feedback": "핵심 개념은 맞지만, 신뢰성 언급이 빠졌습니다.",
     *     "hint": "TCP는 순서 보장과 재전송 기능을 제공합니다.",
     *     "similarity": 0.82,
     *     "interviewLevel": "LEVEL_1",
     *     "categoryName": "네트워크",
     *     "createdAt": "2025-10-31T13:20:45"
     *   },
     *   "message": "SUCCESS"
     * }
     * </code></pre>
     *
     * <p><b>규칙:</b></p>
     * <ul>
     *   <li>JWT 토큰의 userEmail로 로그인된 유저를 식별합니다.</li>
     *   <li>같은 질문(questionId)이라도 여러 번 저장 가능합니다.</li>
     *   <li>유저당 최대 10개까지만 저장 가능 (추후 제한 적용 가능).</li>
     * </ul>
     *
     * @param request   보관함 저장 요청 DTO (questionId, userAnswer, feedback, hint 등)
     * @param userEmail JWT에서 추출된 로그인 사용자 이메일
     * @return 저장된 보관함 데이터(StorageResponse.FindById)를 포함한 공통 응답
     */
    @PostMapping("/storage/save")
    public ResponseEntity<?> saveStorage(@RequestBody StorageRequest.SaveRequest request,
                                         @RequestAttribute("userEmail") String userEmail){


        StorageResponse.FindById response = storageService.saveStorage(request, userEmail);

        return ResponseEntity.ok(CommonResponseDto.success(response, Define.SUCCESS));
    }


    /**
     * <p>사용자의 보관함 데이터를 삭제합니다.</p>
     *
     * <pre><code class="http">
     * 요청 예시:
     * DELETE /api/storages/storage/12/delete
     * Authorization: Bearer {JWT_ACCESS_TOKEN}
     * </code></pre>
     *
     * <pre><code class="json">
     * 응답 예시:
     * {
     *   "success": true,
     *   "data": "처리가 완료 되었습니다",
     *   "message": null
     * }
     * </code></pre>
     *
     * <p><b>동작 규칙:</b></p>
     * <ul>
     *   <li>JWT 토큰에서 추출한 <code>userEmail</code>을 통해 로그인된 사용자를 식별합니다.</li>
     *   <li>삭제 요청된 <code>storageId</code>가 로그인된 사용자의 데이터와 일치해야 삭제됩니다.</li>
     *   <li>다른 사용자의 보관함을 삭제하려 시도할 경우 <code>SecurityException</code>이 발생합니다.</li>
     * </ul>
     *
     * <p><b>삭제 실패 시 예외:</b></p>
     * <ul>
     *   <li>존재하지 않는 storageId → "보관함 데이터를 찾을 수 없습니다."</li>
     *   <li>다른 유저의 데이터 삭제 시 → "본인 보관함만 삭제할 수 있습니다."</li>
     * </ul>
     *
     * @param storageId 삭제할 보관함의 ID (PK)
     * @param userEmail JWT에서 추출된 로그인 사용자 이메일
     * @return 성공 시 "SUCCESS" 메시지를 포함한 공통 응답 객체
     */
    @DeleteMapping("/storage/{id}/delete")
    public ResponseEntity<?> deleteStorage(@PathVariable(name = "id")Long storageId,
                                           @RequestAttribute("userEmail") String userEmail){

        storageService.deleteStorage(storageId, userEmail);

        return ResponseEntity.ok(CommonResponseDto.success(Define.SUCCESS));
    }

    /**
     * <p>로그인한 사용자의 보관함 목록을 조회합니다.</p>
     *
     * <pre><code class="http">
     * 요청 예시:
     * GET /api/storages
     * Authorization: Bearer {JWT_ACCESS_TOKEN}
     * </code></pre>
     *
     * <pre><code class="json">
     * 응답 예시:
     * {
     *   "success": true,
     *   "data": [
     *     {
     *       "storageId": 12,
     *       "questionId": 5,
     *       "questionText": "TCP는 무엇인가요?",
     *       "userAnswer": "TCP는 연결 기반의 프로토콜입니다.",
     *       "feedback": "핵심 개념은 맞지만, 신뢰성 언급이 빠졌습니다.",
     *       "hint": "TCP는 순서 보장과 재전송 기능을 제공합니다.",
     *       "similarity": 0.82,
     *       "interviewLevel": "LEVEL_1",
     *       "categoryName": "네트워크",
     *       "createdAt": "2025-10-31T13:20:45"
     *     },
     *     {
     *       "storageId": 13,
     *       "questionId": 7,
     *       "questionText": "UDP는 무엇인가요?",
     *       "userAnswer": "UDP는 비연결형 프로토콜로, 빠른 전송이 가능합니다.",
     *       "feedback": "좋아요. 단, 신뢰성이 보장되지 않는다는 점도 함께 언급해보세요.",
     *       "hint": "",
     *       "similarity": 0.76,
     *       "interviewLevel": "LEVEL_1",
     *       "categoryName": "네트워크",
     *       "createdAt": "2025-10-31T14:02:11"
     *     }
     *   ],
     *   "message": "SUCCESS"
     * }
     * </code></pre>
     *
     * <p><b>동작 규칙:</b></p>
     * <ul>
     *   <li>JWT 토큰에서 추출한 <code>userEmail</code>을 기반으로 로그인된 사용자를 식별합니다.</li>
     *   <li>해당 사용자가 저장한 모든 보관함(UserStorage) 데이터를 조회합니다.</li>
     *   <li>결과는 최신 등록 순(createdAt DESC)으로 정렬할 수 있습니다 (선택 적용 가능).</li>
     *   <li>조회 결과는 각 보관함 항목별로 질문 정보와 함께 DTO로 변환되어 반환됩니다.</li>
     * </ul>
     *
     * @param userEmail JWT에서 추출된 로그인 사용자 이메일
     * @return 로그인된 사용자의 보관함 목록을 포함한 공통 응답 객체
     */
    @GetMapping
    public ResponseEntity<?> getStorages(@RequestAttribute("userEmail") String userEmail){

        List<StorageResponse.FindAll> list = storageService.getStorageList(userEmail);

        return ResponseEntity.ok(CommonResponseDto.success(list, Define.SUCCESS));
    }


    /**
     * <p>보관함 상세 정보를 조회합니다.</p>
     *
     * <pre><code class="http">
     * 요청 예시:
     * GET /api/storages/12
     * Authorization: Bearer {JWT_ACCESS_TOKEN}
     * </code></pre>
     *
     * <pre><code class="json">
     * 응답 예시:
     * {
     *   "success": true,
     *   "data": {
     *     "storageId": 12,
     *     "questionId": 5,
     *     "questionText": "TCP는 무엇인가요?",
     *     "userAnswer": "TCP는 연결 기반의 프로토콜입니다.",
     *     "feedback": "핵심 개념은 맞지만, 신뢰성 언급이 빠졌습니다.",
     *     "hint": "TCP는 순서 보장과 재전송 기능을 제공합니다.",
     *     "similarity": 0.82,
     *     "interviewLevel": "LEVEL_1",
     *     "categoryName": "네트워크",
     *     "createdAt": "2025-10-31T13:20:45"
     *   },
     *   "message": "SUCCESS"
     * }
     * </code></pre>
     *
     * <p><b>동작 규칙:</b></p>
     * <ul>
     *   <li>JWT 토큰에서 추출한 <code>userEmail</code>을 통해 로그인된 사용자를 식별합니다.</li>
     *   <li>요청한 <code>storageId</code>의 상세 정보를 반환합니다.</li>
     * </ul>
     *
     * <p><b>예외 발생 시:</b></p>
     * <ul>
     *   <li>존재하지 않는 storageId → "보관함 데이터를 찾을 수 없습니다."</li>
     * </ul>
     *
     * @param storageId 조회할 보관함의 ID (PK)
     * @param userEmail JWT에서 추출된 로그인 사용자 이메일
     * @return 해당 보관함(StorageResponse.FindById)의 상세 정보를 포함한 공통 응답 객체
     */

    @GetMapping("/{id}")
    public ResponseEntity<?> getStorageDetail(@PathVariable(name = "id") Long storageId,
                                              @RequestAttribute("userEmail") String userEmail){

        StorageResponse.FindById storage = storageService.getStorageDetail(storageId, userEmail);

        return ResponseEntity.ok(CommonResponseDto.success(storage, Define.SUCCESS));
    }

}
