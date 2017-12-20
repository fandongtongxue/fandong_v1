import Vapor
import MySQLProvider

let USER_DEFAULT_ICON = "http://ov2uvg3mg.bkt.clouddn.com/USER_DEFAULT_ICON.jpg"
let USER_DEFAULT_INTRODUCE = "Nothing to say"

extension Droplet {
    func setupRoutes() throws {
        //MARK: 1.用户相关
        //MARK: 1.1注册用户
        post("userRegister"){ req in
            //获取用户名和密码
            let userName = req.data["userName"]
            let passWord = req.data["passWord"]
            if userName == nil || userName == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "用户名为空",
                    "status":0
                    ])
            }
            if passWord == nil || passWord == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "密码为空",
                    "status":0
                    ])
            }
            //创建MySQL驱动
            let mysqlDriver = try self.mysql()
            //查询是否已存在此用户
            let result = try mysqlDriver.raw("select * from app_user where userName='" + (userName?.string)! + "';")
            if result[0] != nil{
                return try JSON(node: [
                    "data":"",
                    "msg" : "用户已存在,请直接登录",
                    "status":0
                    ])
            }else{
                //用户写入数据库
                let insertMysqlStr = "INSERT INTO app_user(uid,userName,passWord) VALUES(0,'" + (userName?.string)! + "','" +  (passWord?.string)! + "');"
                try mysqlDriver.raw(insertMysqlStr)
                let excuteResult = try mysqlDriver.raw("select * from app_user where userName='" + (userName?.string)! + "';")
                let userinfo = excuteResult[0]
                if userinfo != nil{
                    //写入用户信息表
                    let insertMysqlUserInfoStr = "INSERT INTO app_userInfo(uid,icon,nickName,introduce) VALUES('" + (userinfo?.wrapped["uid"]?.string)!+"','"+USER_DEFAULT_ICON+"','"+(userName?.string)!+"','"+USER_DEFAULT_INTRODUCE+"');"
                    try mysqlDriver.raw(insertMysqlUserInfoStr)
                    let checkUserInfoResult = try mysqlDriver.raw("select * from app_userInfo where uid='" + (userinfo?.wrapped["uid"]?.string)! + "';")
                    if checkUserInfoResult[0] != nil{
                        return try JSON(node: [
                            "data":["uid":(userinfo?.wrapped["uid"]?.string)!],
                            "msg" : "注册成功",
                            "status":1
                            ])
                    }
                }
                return try JSON(node: [
                    "data":"",
                    "msg" : "注册失败",
                    "status":0
                    ])
            }
        }
        //MARK: 1.2用户登录
        post("userLogin"){ req in
            //获取用户名和密码
            let userName = req.data["userName"]
            let passWord = req.data["passWord"]
            if userName == nil || userName == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "用户名为空",
                    "status":0
                    ])
            }
            if passWord == nil || passWord == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "密码为空",
                    "status":0
                    ])
            }
            //创建MySQL驱动
            let mysqlDriver = try self.mysql()
            //查询是否已存在此用户
            let result = try mysqlDriver.raw("select * from app_user where userName='" + (userName?.string)! + "';")
            if result[0] != nil{
                //判断密码是否正确
                //创建Drop
                let config = try Config()
                try config.setup()
                let drop = try Droplet(config)
                //GET中的密码哈希值
                let getPassWordHash = try drop.hash.make((passWord?.string)!)
                let getPassWordHashStr = getPassWordHash.makeString()
                //MySQL中密码的哈希值
                let resultNode = result[0] as! Node
                let resultStructuredData = resultNode.wrapped as! StructuredData
                let mysqlPasswordStr = (resultStructuredData["passWord"]?.string)!
                let mysqlPasswordHash = try drop.hash.make(mysqlPasswordStr)
                let mysqlPasswordHashStr = mysqlPasswordHash.makeString()
                //密码验证
                if getPassWordHashStr == mysqlPasswordHashStr {
                    let checkUserInfoResult = try mysqlDriver.raw("select * from app_userInfo where uid='" + (result[0]?.wrapped["uid"]?.string)! + "';")
                    if checkUserInfoResult[0] != nil{
                        return try JSON(node: [
                            "data":["uid":(result[0]?.wrapped["uid"]?.string)!],
                            "msg" : "登录成功",
                            "status":1
                            ])
                    }
                }
                return try JSON(node: [
                    "data":"",
                    "msg" : "密码错误",
                    "status":0
                    ])
            }
            return try JSON(node: [
                "data":"",
                "msg" : "用户不存在,请先注册",
                "status":0
                ])
        }
        //MARK: 1.3已知密码修改密码
        post("userChangePassWord"){ req in
            //获取GET数据
            let userName = req.data["userName"]
            let oldPassWord = req.data["oldPassWord"]
            let newPassWord = req.data["newPassWord"];
            if userName == nil || userName == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "用户名为空",
                    "status":0
                    ])
            }
            if oldPassWord == nil || oldPassWord == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "原密码为空",
                    "status":0
                    ])
            }
            if newPassWord == nil || newPassWord == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "新密码为空",
                    "status":0
                    ])
            }
            //判断原密码是否正确
            //创建MySQL驱动
            let mysqlDriver = try self.mysql()
            //查询是否已存在此用户
            let result = try mysqlDriver.raw("select * from app_user where userName='" + (userName?.string)! + "';")
            if result[0] != nil{
                //判断密码是否正确
                //创建Drop
                let config = try Config()
                try config.setup()
                let drop = try Droplet(config)
                //GET中的密码哈希值
                let getPassWordHash = try drop.hash.make((oldPassWord?.string)!)
                let getPassWordHashStr = getPassWordHash.makeString()
                //MySQL中密码的哈希值
                let resultNode = result[0] as! Node
                let resultStructuredData = resultNode.wrapped as! StructuredData
                let mysqlPasswordStr = (resultStructuredData["passWord"]?.string)!
                let mysqlPasswordHash = try drop.hash.make(mysqlPasswordStr)
                let mysqlPasswordHashStr = mysqlPasswordHash.makeString()
                //密码验证
                if getPassWordHashStr != mysqlPasswordHashStr {
                    return try JSON(node: [
                        "data":"",
                        "msg" : "原密码错误",
                        "status":0
                        ])
                }
                //覆盖原密码
                let updateMysqlStr = "UPDATE app_user SET passWord = '" + (newPassWord?.string)! + "' WHERE userName = '" + (userName?.string)! + "';"
                try mysqlDriver.raw(updateMysqlStr)
                return try JSON(node: [
                    "data":"",
                    "msg" : "修改密码成功",
                    "status":1
                    ])
            }
            //正确的话覆盖原密码
            return try JSON(node: [
                "data":"",
                "msg" : "用户不存在,请先注册",
                "status":0
                ])
        }
        //MARK: 1.4获取用户信息
        get("userInfo"){ req in
            let uid = req.data["uid"]
            if uid == nil || uid == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "uid为空",
                    "status":0
                    ])
            }
            //创建MySQL驱动
            let mysqlDriver = try self.mysql()
            //查询是否已存在此用户
            let result = try mysqlDriver.raw("select * from app_userInfo where uid='" + (uid?.string)! + "';")
            if result[0] != nil{
                return try JSON(node: [
                    "data":["userInfo":JSON(result)],
                    "msg" : "获取用户信息成功",
                    "status":1
                    ])
            }
            return try JSON(node: [
                "data":"",
                "msg" : "用户不存在,请先注册",
                "status":0
                ])
        }
        //MARK: 1.5更改用户信息昵称/简介/头像
        post("userChangeUserInfo"){ req in
            //获取GET数据
            let nickName = req.data["nickName"]
            let introduce = req.data["introduce"]
            let icon = req.data["icon"]
            let uid = req.data["uid"];
            if uid == nil || uid == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "uid为空",
                    "status":0
                    ])
            }
            if nickName == nil || nickName == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "nickName为空",
                    "status":0
                    ])
            }
            if introduce == nil || introduce == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "introduce为空",
                    "status":0
                    ])
            }
            if icon == nil || icon == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "icon为空",
                    "status":0
                    ])
            }
            //创建MySQL驱动
            let mysqlDriver = try self.mysql()
            let updateMysqlStr = "UPDATE app_userInfo SET nickName = '" + (nickName?.string)! + "', introduce = '" + (introduce?.string)! + "',icon = '" + (icon?.string)! +  "' WHERE uid = '" + (uid?.string)! + "';"
            try mysqlDriver.raw(updateMysqlStr)
            return try JSON(node: [
                "data":"",
                "msg" : "更新用户信息成功",
                "status":1
                ])
        }
        //MARK: 2.电视台
        //MARK: 2.1电视台列表
        get("channelList"){ req in
            //创建MySQL驱动
            let mysqlDriver = try self.mysql()
            let result = try mysqlDriver.raw("select * from app_channelList;")
            return try JSON(node: [
                "data":["channelList":JSON(result)],
                "msg" : "获取电视台列表成功",
                "status":1
                ])
        }
        //MARK: 3.HTML
        //MARK: 3.1 CMS
        get("cms"){ req in
            //创建Drop
            let config = try Config()
            try config.setup()
            let drop = try Droplet(config)
            return try drop.view.make("cms.html", ["greeting": "Hello World"])
        }
        //MARK: 3.2 About
        get("about"){ req in
            //创建Drop
            let config = try Config()
            try config.setup()
            let drop = try Droplet(config)
            return try drop.view.make("about.html", ["greeting": "Hello World"])
        }
        //MARK: 4.动态
        //MARK: 4.1发布动态
        post("statusPublish"){ req in
            //获取GET数据
            let imgUrls = req.data["imgUrls"]
            let content = req.data["content"]
            let location = req.data["location"]
            let uid = req.data["uid"];
            if uid == nil || uid == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "uid为空",
                    "status":0
                    ])
            }
            if content == nil || content == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "content为空",
                    "status":0
                    ])
            }
            if location == nil || location == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "location为空",
                    "status":0
                    ])
            }
            //写入动态列表表
            //创建MySQL驱动
            let mysqlDriver = try self.mysql()
            let insertMysqlUserInfoStr = "INSERT INTO app_statusList(uid,imgUrls,content,location,likeCount,commentCount,shareCount) VALUES('" + (uid?.string)! + "','" + (imgUrls?.string)! + "','"+(content?.string)! + "','" + (location?.string)! + "','0','0','0');"
            try mysqlDriver.raw(insertMysqlUserInfoStr)
            return try JSON(node: [
                "data":"",
                "msg" : "动态发布成功",
                "status":1
                ])
        }
        //MARK: 4.2动态列表
        get("statusList"){ req in
            let uid = req.data["uid"]
            //创建MySQL驱动
            let mysqlDriver = try self.mysql()
            var mysqlStr = ""
            if uid == nil || uid == ""{
                mysqlStr = "select * from app_statusList order by id desc;"
            }else{
                mysqlStr = "select * from app_statusList Where uid = " + (uid?.string)! + " order by id desc;"
            }
            let statusResult = try mysqlDriver.raw(mysqlStr)
            for status in statusResult.array!{
                let statusObject = status.wrapped.object
                let uid = statusObject!["uid"]
                //TODO根据uid查询用户信息
                let mysqlUserInfoSql = "select * from app_userInfo where uid='" + (uid?.string)! + "';"
                let userInfoResult = try mysqlDriver.raw(mysqlUserInfoSql)
                self.log.info(userInfoResult.wrapped.description)
            }
            if statusResult[0] != nil{
                return try JSON(node: [
                    "data":["statusList":JSON(statusResult)],
                    "msg" : "获取动态列表成功",
                    "status":1
                    ])
            }
            return try JSON(node: [
                "data":"",
                "msg" : "获取动态列表失败",
                "status":0
                ])
        }
        //MARK: 5.评论
        //MARK: 5.1评论
        post("comment"){req in
            let uid = req.data["uid"]
            let objectId = req.data["objectId"]
            let type = req.data["type"]
            let comment = req.data["comment"]
            if uid == nil || uid == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "uid为空",
                    "status":0
                    ])
            }
            if objectId == nil || objectId == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "objectId为空",
                    "status":0
                    ])
            }
            if type == nil || type == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "type为空",
                    "status":0
                    ])
            }
            if comment == nil || comment == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "comment为空",
                    "status":0
                    ])
            }
            let mysqlDriver = try self.mysql()
            //用户写入数据库
            let currentDate = Date.init(timeIntervalSinceNow: 0)
            let currentDateString = currentDate.smtpFormatted
            
            let insertMysqlStr = "INSERT INTO app_commentList(uid,objectId,comment,createTime) VALUES('" + (uid?.string)! + "','" +  (objectId?.string)! + "','" + (comment?.string)! + "','" + currentDateString + "');"
            try mysqlDriver.raw(insertMysqlStr)
            let excuteResult = try mysqlDriver.raw("select * from app_commentList where comment='" + (comment?.string)! + "';")
            let userinfo = excuteResult[0]
            if userinfo != nil{
                return try JSON(node: [
                    "data":"",
                    "msg" : "评论成功",
                    "status":1
                    ])
            }
            return try JSON(node: [
                "data":"",
                "msg" : "评论失败",
                "status":0
                ])
        }
        //MARK: 5.1评论列表
        get("commentList"){ req in
            let objectId = req.data["objectId"]
            let type = req.data["type"]
            if objectId == nil || objectId == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "objectId为空",
                    "status":0
                    ])
            }
            if type == nil || type == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "type为空",
                    "status":0
                    ])
            }
            //创建MySQL驱动
            let mysqlDriver = try self.mysql()
            if type?.string?.int == 0{
                let result = try mysqlDriver.raw("select * from app_channel_comment where channelId='" + (objectId?.string)! + "' order by id desc;")
                if result[0] != nil{
                    return try JSON(node: [
                        "data":["commentList":JSON(result)],
                        "msg" : "获取评论列表成功",
                        "status":1
                        ])
                }
                return try JSON(node: [
                    "data":"",
                    "msg" : "获取评论列表失败",
                    "status":0
                    ])
            }
            return try JSON(node: [
                "data":"",
                "msg" : "操作失败",
                "status":0
                ])
        }
        //MARK:
        post("expireDate") { req in
            let uuid = req.data["uuid"]
            if uuid == nil || uuid == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "uuid为空",
                    "status":0
                    ])
            }
            let mysqlDriver = try self.mysql()
            let uuidResult = try mysqlDriver.raw("select * from app_WingMan_ExpireDate where uuid='" + (uuid?.string)! + "';")
            let uuidInfo = uuidResult[0]
            let currentDate = Date.init(timeIntervalSinceNow: 0)
            let currentDateString = currentDate.smtpFormatted
            if uuidInfo == nil{
                let expireDate = Date.init(timeIntervalSinceNow: 3600*24)
                let expireDateString = expireDate.smtpFormatted
                
                let insertMysqlStr = "INSERT INTO app_WingMan_ExpireDate(uuid,currentDate,expireDate) VALUES('" + (uuid?.string)! + "','" + currentDateString + "','" +  expireDateString + "');"
                try mysqlDriver.raw(insertMysqlStr)
                let excuteResult = try mysqlDriver.raw("select * from app_WingMan_ExpireDate where uuid='" + (uuid?.string)! + "';")
                let userinfo = excuteResult[0]
                if userinfo != nil{
                    return try JSON (node: [
                        "data":["expireDate":expireDateString,"currentDate":currentDateString],
                        "msg" : "获取当前时间和到期时间成功",
                        "status":1
                        ])
                }
                return try JSON (node: [
                    "data":"",
                    "msg" : "获取当前时间和到期时间失败",
                    "status":0
                    ])
            }else{
                let uuidinfoObject = uuidInfo?.wrapped.object
                return try JSON (node: [
                    "data":["expireDate":uuidinfoObject!["expireDate"]!,"currentDate":currentDateString],
                    "msg" : "获取当前时间和到期时间成功",
                    "status":1
                    ])
            }
        }
        //MARK: 更新到期时间
        post("updateExpireDate") { req in
            let uuid = req.data["uuid"]
            let productId = req.data["productId"]
            if uuid == nil || uuid == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "uuid为空",
                    "status":0
                    ])
            }
            if productId == nil || productId == ""{
                return try JSON(node: [
                    "data":"",
                    "msg" : "productId为空",
                    "status":0
                    ])
            }
            
            let productIdDict = ["WingMan001":"7",
                                 "WingMan002":"30",
                                 "WingMan003":"120",
                                 "WingMan004":"365",
                                 "WingMan005":"1800"]
            let productIdResult = productIdDict[(productId?.string)!]
            let productIdDay = productIdResult?.double
            
            let mysqlDriver = try self.mysql()
            let excuteResult = try mysqlDriver.raw("select * from app_WingMan_ExpireDate where uuid='" + (uuid?.string)! + "';")
            let uuidResult = excuteResult[0]
            let uuidObject = uuidResult?.wrapped.object
//            let oldCurrentDateString = uuidObject!["currentDate"]
            let oldExpireDateString = uuidObject!["expireDate"]?.string
            //解决如下错误
            //Printing description of originDate:
            //"Wed, 3 Jan 2018 15:40:03 +0800, currentDate = Wed, 20 Dec 2017 15:40:04 +0800"
            let trueString = oldExpireDateString?.components(separatedBy: ", currentDate").first
            
            let oldExpireDate = AppTool.shared.translateStringToDate(originDate: trueString!)
            
            let currentDate = Date.init(timeIntervalSinceNow: 0)
            var expireDate = Date()
            
            let compareResult = oldExpireDate.compare(currentDate)
            if compareResult == .orderedDescending{
                //老过期时间大于当前服务器时间,在这个基础上加购买的时间
                let timeIntervalSinceOldDate = oldExpireDate.timeIntervalSinceNow
                expireDate = Date.init(timeIntervalSinceNow: timeIntervalSinceOldDate + 3600*24*productIdDay!)
            }else{
                //老过期时间小于当前服务器时间,在当前时间上加购买的时间
                expireDate = Date.init(timeIntervalSinceNow: 3600*24*productIdDay!)
            }
            
            let currentDateString = currentDate.smtpFormatted
            let expireDateString = expireDate.smtpFormatted
            
            if excuteResult[0] != nil{
                let updateMysqlStr = "UPDATE app_WingMan_ExpireDate SET expireDate = '" + expireDateString + ", currentDate = " + currentDateString +  "' WHERE uuid = '" + (uuid?.string)! + "';"
                _ = try mysqlDriver.raw(updateMysqlStr)
                return try JSON(node: [
                    "data":"",
                    "msg" : "更新到期时间成功",
                    "status":1
                    ])
            }
            return try JSON(node: [
                "data":"",
                "msg" : "更新到期时间失败",
                "status":0
                ])
        }
    }
}
