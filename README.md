# Travely
🎒[Travely-Client](https://github.com/rlawndud/Travely.git)

🎒[Travely-Main Server](https://github.com/rlawndud/Travely_Server.git)

🎒[Travely-AI Server](https://github.com/rlawndud/Travely_AiServer.git)

## 목차
[실행 방법]()
[화면 구성]()
[팀이란?]()
[기술 스택]()
## 실행 방법
실행환경 및 라이브러리는 하단 기술 스택 참조
### Main Server
1. Travely_Server 파일을 PyCharm으로 실행
2. websocketserver 파일에서 모델서버와의 연결을 위해 serverhost와 serverport를 AI서버의 주소에 맞게 값을 변경
```python
# 모델통신
self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
self.serverhost = '220.90.180.88'
self.serverport = 5001
self.reader = None
self.writer = None
self.lock = asyncio.Lock()
```
3. MYSQL과 연동을 위해 websocketserver파일에서 유저명, 비밀번호, 참조할 DB의 이름을 설정
```python
def connect_to_db():
    global conn
    try:
        conn = pymysql.connect(
            host="127.0.0.1",
            user="root",
            password="1234",
            db="bit",
            charset="utf8"
        )
        print("Database connection successful.")
        return conn
    except pymysql.MySQLError as e:
        print(f"Database connection failed: {e}")
        return None
```
4. 서버 실행을 위해 server파일에서 ip주소와 port번호를 서버컴퓨터의 환경에 맞게 값을 변경. 그 후 server 파일 실행
```python
server = WebsocketServer(hostadr="0.0.0.0", port=8080)
```
### AI Server
1. server_reaction파일의 reaction.py를 PyCharm으로 실행
   해당 파일에서 메인 서버와의 연결을 위해 serverhost와 serverport를 현재의 주소에 맞게 값을 변경
```python
# 로깅 설정
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

HOST = '220.90.180.88'
PORT = 5001
Face_MODEL_DIR = 'face_models'
if not os.path.exists(Face_MODEL_DIR):
    os.makedirs(Face_MODEL_DIR)
```
### Client
※ 메인 서버 및 AI서버가 실행되어 있어야 함.
1. Travely.apk 파일 다운로드 <br>
   ▸ [Travely.apk 드라이브](https://drive.google.com/file/d/1EaEVQhjnvwcDheTc9i5SGJP3PjgChc6n/view?usp=sharing)
2. Travely 실행
3. 회원가입 후 어플리케이션 사용

## 화면 구성
### **로그인 - 회원가입**

![image](https://github.com/user-attachments/assets/e07c9ee4-46d1-449a-bf1a-35b02fc6caa2)
![image](https://github.com/user-attachments/assets/84fb919e-b903-4393-9ba0-350dce862400)

:회원가입 시, 회원의 얼굴 사진을 정면, 상하좌우의 측면으로 5장의 사진을 촬영한 후 회원가입을 진행한다.

### **여행 팀 생성 및 구성**

![image](https://github.com/user-attachments/assets/6c6b0784-b177-4231-b371-8d9178a1896b)
![image](https://github.com/user-attachments/assets/719f0707-8429-447f-aee6-1e37c02098c8)

:팀 이름을 입력하고 생성버튼을 눌러 팀을 생성하고,
팀원의 아이디를 입력하고 초대버튼을 눌러 현재 팀으로 설정된 팀에 초대할 수 있다.

여행 시작 버튼을 누르면 현재 팀의 얼굴모델이 생성되어, **사진촬영이 가능**해진다.

### **앨범**
![image](https://github.com/user-attachments/assets/cb09c188-a754-4ffa-bde4-1e5882a3fff7)
![image](https://github.com/user-attachments/assets/f62b9fd8-c0f2-4048-8677-e4f4783cd913)
![image](https://github.com/user-attachments/assets/83f7b1cc-c79e-4cdc-b829-901b73a60597)
![image](https://github.com/user-attachments/assets/d7b5e231-1978-498e-be21-84b1656d025f)

얼굴인식, 배경예측, 이미지 문장생성의 결과를 이미지 상세보기에서 확인할 수 있다.

**검색 기능**

![image](https://github.com/user-attachments/assets/4d518a6b-935b-4679-af14-afc554a1d7b6)

### **지도 관련 기능(팀원위치 공유, 위치기반 앨범)**

![image](https://github.com/user-attachments/assets/7c4fb183-fc85-4888-8fb6-81f47911bfda)
![image](https://github.com/user-attachments/assets/f99d6c13-c5c7-45ea-8d43-c6ba25fbf34f)

### **카메라**
![image](https://github.com/user-attachments/assets/78fa6228-f4a4-4e9c-92b2-3b82a4fa41f7)

## 팀이란?

사진 촬영 시 팀 앨범에서 실시간으로 팀원 간 사진 공유가 가능하며, 지도에서 다른 팀원과 위치를 공유할 수 있다.

## 📚기술 스택
### Environment

![PyCharm](https://img.shields.io/badge/pycharm-143?style=for-the-badge&logo=pycharm&logoColor=black&color=black&labelColor=green) ![Anaconda](https://img.shields.io/badge/Anaconda-%2344A833.svg?style=for-the-badge&logo=anaconda&logoColor=white) <img src="https://img.shields.io/badge/mysql-4479A1?style=for-the-badge&logo=mysql&logoColor=white"> <img src="https://img.shields.io/badge/github-181717?style=for-the-badge&logo=github&logoColor=white"> 
<br>

### Development

<img src="https://img.shields.io/badge/python-3776AB?style=for-the-badge&logo=python&logoColor=white"> <img src="https://img.shields.io/badge/flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"> ![Figma](https://img.shields.io/badge/figma-%23F24E1E.svg?style=for-the-badge&logo=figma&logoColor=white)
<br>
--

서버 : PyCham 2024.1.1 , Python 3.10 , Anaconda 2.5.2 |
라이브러리 : cv2 4.10.0.84, numpy 2.0.1 , websocket 12.0, PyMySQL 1.1.1, requests 2.32.3

데이터베이스 : MySQL 8.0.39

AI서버 : PyCharm 2024.1.1, Pyhton 3.8

클라이언트 : Android Studio 2024.1.1 , Flutter 4.0.0 , Figma 124.1.16 |
라이브러리 : Web socket 3.0.1 , Google Maps 2.1.12
