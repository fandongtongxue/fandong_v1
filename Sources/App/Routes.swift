import Vapor
import MySQLProvider

extension Droplet {
    func setupRoutes() throws {
        //注册用户
        get("registerUser"){ req in
            //没有用户名
            let username = req.data["username"]
            if username == nil{
            return try JSON(node: [
                "data":"",
                "msg" : "用户名为空",
                "state":0
                ])
            }
            //没有密码
            let password = req.data["password"]
            if password == nil{
                return try JSON(node: [
                    "data":"",
                    "msg" : "密码为空",
                    "state":0
                    ])
            }
            //创建MySQL驱动
            let mysqlDriver = try self.mysql()
            //先判断有没有用户表(没有用户表创建用户表)
            //查询是否已存在此用户
            let result = try mysqlDriver.raw("select * from app_user where username='" + (username?.string)! + "';")
            let userinfo = result[0]
            if userinfo != nil{
                return try JSON(node: [
                    "data":"",
                    "msg" : "用户已存在,请直接登录",
                    "state":0
                    ])
            }
            return "注册用户"
        }
    }
}
