
## 최근 구현했던 서버의 인프라 구조

### GameServer(HTTPS)
```
Node.js(Express)
Auto Scaling
```

### RDS
```
AuroraDB
Master/Slave
```

### Chat & Raid
```
C++
Boost Asio
Protocol Buffer
```

### DB Agent
```
Node.js
채팅서버와 레이드서버의 DB처리
```

### Item Provider
```
퍼블리셔의 아이템 지급 명령(결제, 쿠폰, 이벤트 등) 처리
```

### GM Tool & Log
```
AngularJS
FluentD
Google Bigquery
```



