import Vapor
import MySQLProvider

extension Droplet {
    func setupRoutes() throws {
        //1.用户相关
        //1.1注册用户
        get("registerUser"){ req in
            //获取用户名和密码
            let username = req.data["userName"]
            let password = req.data["passWord"]
            //创建MySQL驱动
            let mysqlDriver = try self.mysql()
            //查询是否已存在此用户
            let result = try mysqlDriver.raw("select * from app_user where userName='" + (username?.string)! + "';")
            if result[0] != nil{
                return try JSON(node: [
                    "data":"",
                    "msg" : "用户已存在,请直接登录",
                    "state":0
                    ])
            }else{
                //用户写入数据库
                let insertMysqlStr = String.init(format: "INSERT INTO app_user(uid,userName,passWord) VALUES(0,'%@','%@');", (username?.string)!,(password?.string)!)
                let insertResult = try mysqlDriver.raw(insertMysqlStr)
                print("注册用户结果:"+insertResult.string!)
                let excuteResult = try mysqlDriver.raw("select * from app_user where userName='" + (username?.string)! + "';")
                let userinfo = excuteResult[0]
                if userinfo == nil{
                    return try JSON(node: [
                        "data":"",
                        "msg" : "注册失败",
                        "state":0
                        ])
                }else{
                    return try JSON(node: [
                        "data":"",
                        "msg" : "注册成功",
                        "state":1
                        ])
                }
            }
        }
    }
}
