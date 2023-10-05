# MacC-Team11-UMM
Macro Challenge, Team 11, UMM, Morning, 2023

# 팀 개발자들을 위한 Git, Code Convention

## 네이밍
- 이슈</br>
  `이슈 핵심 내용`</br>
  `구글 로그인 구현`</br>

- 브랜치</br>
  `브랜치 종류/이슈 번호-개발할 기능 이름`</br>
  `feat/1-login-view`</br>
  
- 커밋</br>
  `(종류 이모지)[이슈 번호] 이슈 핵심 내용`</br>
  `:bug:[#11][#12] 구글 로그인 탈퇴시 발생하는 버그 해결`</br>
  
- PR</br>
  `(종류 이모지)[이슈 번호] 커밋 내용`</br>
  `:zap:[#1] 로그인 화면 개발`</br>

## 브랜치, 커밋 종류
|           종류              | 이모지                                          |       설명               |
|:---------------------------|:----------------------------------------------|:------------------------|
| initial                    | :tada: `:tada:`                               | 초기 설정                 |
| refactor                   | :recycle: `:recycle:`                         | 파일·타입 이름 변경, 파일 분리 |
| bug                        | :bug: `:bug:`                                 | 버그                     |
| feat                       | :zap: `:zap:`                                 | 기능                     |
| gui                        | :art: `:art:`                                 | View                    |
| chore                      | :broom: `:broom:`                             | SPM, 세팅, 빌드 등         |
| delete                     | :wastebasket: `:wastebasket:`                 | 파일 삭제                 |
| docs                       | :books: `:books:`                             | 코드 외 문서               |
| asset                      | :heart: `:heart:`                             | 에셋                     |
| comment                    | :memo: `:memo:`                               | 주석                     |

## 내용
- 이슈, PR은 템플릿을 따릅니다
- 커밋
  한 줄로 간결하게 작성하고 작성해야 하는 내용이 길어지면 한 줄 개행 후 상세 내용을 작성합니다
  ```markdown
  [fix][#11] 버튼이 동작하지 않는 버그 해결
  
  - 화면을 나갔다가 다시 들어오면 버튼이 비활성화되었음
  - 어쩌구저쩌구 원인으로 인해 발생
  - 어떻게 해서 저렇게 하는 방법으로 해결
  ```

## 생성

한 이슈당 브랜치 하나 1:1

  1. Create a branch를 눌러 origin(기본 브랜치)에서 먼저 생성
  2. 또는 local에서 먼저 생성해서 작업 후 push origin 후에 톱니바퀴⚙️를 눌러 이슈와 연결
      

## 삭제

- Git flow에 해당하지 않는 브랜치는 머지 후 삭제합니다
- [Exeption] 해당하는 이슈 내 태스크가 완료되지 않았지만 기타 사유로 일단 머지하는 경우

## Code Review 코드 리뷰

### 방식에 대하여
- 본인 외 2인의 승인 필요(사실상 테크 전원)
- PR을 올린 다음날 아침 10시까지, 주말 포함

### 작업 순서
#### push: 보낼 때
{working directory}</br>
-> git add -> {staging area} </br>
-> git commit -> {local repository == 나의 mac}</br>
-> git pull 후 충돌 발생하면 로컬에서 해결</br>
-> git push -> {remote repository == github}</br>

#### 깃헙 페이지에서의 Pull Request
1. PR 생성 버튼 누르기
2. PR 컨벤션에 따라 작성하기
3. 코드 리뷰와 승인 받기
4. (승인 받지 못한 경우에 코드 수정하기)
5. 병합하기
6. 리모트 브랜치 삭제하기

#### pull: 받을 때
{remote repository}</br>
-> git pull -> {local repository}</br>
-> git branch -d {prev}</br>
-> git branch {new} -> git checkout {new} -> {working directory}</br>


### 코드 컨벤션
- 주석은 복잡한 기능 등을 한줄요약하는 정도로만 사용합니다. 레거시 주석이 되지 않게 일반적인 내용을 적습니다.
- 린트 사용

### 코드리뷰 약어
- **IMO** in my opinion
- **LGTM** look good to me
- **FYI** for your information
- **ASAP** as soon as possible
- **TL;DR** Too Long. Didn't Read *보통 문장 앞 부분에 긴 글을 요약할 때*
- **P1 ~ P3** 우선순위. 1이 높은 것.
  

### 
