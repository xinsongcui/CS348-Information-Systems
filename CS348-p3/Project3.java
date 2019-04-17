import java.sql.*;
import java.io.*;

public class Project3 {
    // JDBC driver name and database URL
    static final String JDBC_DRIVER = "ojdbc8.jar";
    static final String DB_URL = "jdbc:oracle:thin:@claros.cs.purdue.edu:1524:strep";

    //  Database credentials
    static final String USER = "cui102";
    static final String PASS = "jupYgBdG";

    public static void main(String[] args) {
        Connection conn = null;
        Statement stmt = null;
        String input = args[0];
        String output = args[1];


        try{
            //STEP 2: Register JDBC driver
            Class.forName("oracle.jdbc.OracleDriver");

            //STEP 3: Open a connection
            System.out.println("Connecting to database...");
            conn = DriverManager.getConnection(DB_URL,USER,PASS);

            //STEP 4: Execute a query
            System.out.println("Creating statement...");
            stmt = conn.createStatement();
            String sql;
            ResultSet rs = null;
            String current_user = null;
            int current_uID = 0;
            String line = null;
            int i = 1;
            int roleID = 2;
            int userID = 2;

            FileWriter fr = new FileWriter(output);
            BufferedReader br = new BufferedReader(new FileReader(input));
            //STEP 5: Extract data from result set
            while((line = br.readLine()) != null) {
                System.out.println(i + ": " + line);
                fr.write(i + ": " + line + "\n");

                String cmd[] = line.split(" ");

                if (cmd[0].equals("LOGIN")) {
                    sql = "SELECT * FROM Users WHERE UserName='" + cmd[1] + "'";
                    rs = stmt.executeQuery(sql);
                    if (rs.next()) {
                        if (cmd[1].equals(rs.getString("Username")) && cmd[2].equals(rs.getString("Password"))) {
                            current_user = cmd[1];
                            current_uID = rs.getInt("UserId");
                            System.out.println("Login successful");
                            fr.write("Login successful\n");
                        } else {
                            System.out.println("Invalid login");
                            fr.write("Invalid login\n");
                        }
                    }
                    else{
                        System.out.println("Invalid login");
                        fr.write("Invalid login\n");
                    }
                }

                if (cmd[0].equals("CREATE") && cmd[1].equals("ROLE")){
                    if (current_user.equals("admin")){
                        sql = "INSERT INTO Roles " +  "VALUES ( " + Integer.toString(roleID) + ", '" + cmd[2] + "')";
                        stmt.executeUpdate(sql);
                        System.out.println("Role created successfully");
                        fr.write("Role created successfully\n");
                        roleID++;
                    }
                    else{
                        System.out.println("Authorization failure");
                        fr.write("Authorization failure\n");
                    }
                }

                if (cmd[0].equals("CREATE") && cmd[1].equals("USER")){
                    if(current_user.equals("admin")){
                        sql = "INSERT INTO Users " +  "VALUES ( " + Integer.toString(userID) + ", '" + cmd[2] + "', '" + cmd[3] + "')";
                        stmt.executeUpdate(sql);
                        System.out.println("User created successfully");
                        fr.write("User created successfully\n");
                        userID++;
                    }
                    else{
                        System.out.println("Authorization failure");
                        fr.write("Authorization failure\n");
                    }

                }

                if (cmd[0].equals("ASSIGN") && cmd[1].equals("ROLE")){
                    if(current_user.equals("admin")){
                        int uID = 0;
                        int rID = 0;

                        sql = "SELECT * FROM Users WHERE UserName='" + cmd[2] + "'";
                        rs = stmt.executeQuery(sql);
                        if (rs.next()) {
                            uID = rs.getInt("UserId");
                        }

                        sql = "SELECT * FROM Roles WHERE RoleName='" + cmd[3] + "'";
                        rs = stmt.executeQuery(sql);
                        if (rs.next()) {
                            rID = rs.getInt("RoleId");
                        }

                        sql = "INSERT INTO UserRoles " +  "VALUES ( " + Integer.toString(uID) + ", "  + Integer.toString(rID) + ")";
                        stmt.executeUpdate(sql);
                        System.out.println("Role assigned successfully");
                        fr.write("Role assigned successfully\n");
                    }
                    else{
                        System.out.println("Authorization failure");
                        fr.write("Authorization failure\n");
                    }
                }

                if (cmd[0].equals("GRANT") && cmd[1].equals("PRIVILEGE")){
                    if(current_user.equals("admin")){
                        int rID = 0;
                        int pID = 0;

                        sql = "SELECT * FROM Privileges WHERE PrivName='" + cmd[2] + "'";
                        rs = stmt.executeQuery(sql);
                        if (rs.next()) {
                            pID = rs.getInt("PrivId");
                        }

                        sql = "SELECT * FROM Roles WHERE RoleName='" + cmd[4] + "'";
                        rs = stmt.executeQuery(sql);
                        if (rs.next()) {
                            rID = rs.getInt("RoleId");
                        }

                        sql = "INSERT INTO UserPrivileges " +  "VALUES ( " + Integer.toString(rID) +
                                ", "  + Integer.toString(pID) + ", '" + cmd[6] + "')";
                        stmt.executeUpdate(sql);
                        System.out.println("Privilege granted successfully");
                        fr.write("Privilege granted successfully\n");
                    }
                    else{
                        System.out.println("Authorization failure");
                        fr.write("Authorization failure\n");
                    }
                }

                if (cmd[0].equals("REVOKE") && cmd[1].equals("PRIVILEGE")){
                    if(current_user.equals("admin")){
                        int pID = 0;
                        int rID = 0;

                        sql = "SELECT * FROM Privileges WHERE PrivName='" + cmd[2] + "'";
                        rs = stmt.executeQuery(sql);
                        if (rs.next()) {
                            pID = rs.getInt("PrivId");
                        }

                        sql = "SELECT * FROM Roles WHERE RoleName='" + cmd[4] + "'";
                        rs = stmt.executeQuery(sql);
                        if (rs.next()) {
                            rID = rs.getInt("RoleId");
                        }

                        sql = "DELETE FROM UserPrivileges WHERE RoleId=" + Integer.toString(rID) +
                                "AND PrivId=" + Integer.toString(pID) + "AND TableName='" + cmd[6] +"'";
                        stmt.executeUpdate(sql);
                        System.out.println("Privilege granted successfully");
                        fr.write("Privilege granted successfully\n");
                    }
                     else{
                        System.out.println("Authorization failure");
                        fr.write("Authorization failure\n");
                    }
                }

                if (cmd[0].equals("INSERT") && cmd[1].equals("INTO")){
                    sql = "SELECT * FROM UserRoles, UserPrivileges WHERE UserRoles.RoleId = UserPrivileges.RoleId " +
                            "AND UserPrivileges.TableName= '" + cmd[2] + "'" +
                            "AND UserPrivileges.PrivId = 1 AND UserRoles.UserId = " + Integer.toString(current_uID);
                    rs = stmt.executeQuery(sql);
                    if (rs.next()) {
                        String inst ="";
                        int k = 0;
                        for (int j = 0; j<cmd.length; j++){

                            if(cmd[j].equals("VALUES")){
                                k = 1;
                                cmd[j+1] = "(" + cmd[j+1].substring(2,cmd[j+1].length()-2) + ",";
                            }
                            if(cmd[j].equals("GET")){
                                k = 0;
                            }
                            if(k == 1){
                                inst = inst + cmd[j] + " ";
                            }

                        }
                        int rID = 0;
                        inst = inst.substring(0, inst.length()-2);
                        inst = inst + ", ";
                        sql = "SELECT * FROM Roles WHERE RoleName='" + cmd[cmd.length-1] + "'";
                        rs = stmt.executeQuery(sql);
                        if (rs.next()) {
                            rID = rs.getInt("RoleId");
                        }
                        inst = inst + Integer.toString(rID) + ")";


                        sql = "INSERT INTO " + cmd[2] + " " + inst;
                        stmt.executeUpdate(sql);
                        System.out.println("Row inserted successfully");
                        fr.write("Row inserted successfully\n");

                    }
                    else{
                        System.out.println("Authorization failure");
                        fr.write("Authorization failure\n");
                    }
                }

                if (cmd[0].equals("SELECT") && cmd[1].equals("*") && cmd[2].equals("FROM")){
                    sql = "SELECT * FROM UserRoles, UserPrivileges WHERE UserRoles.RoleId = UserPrivileges.RoleId " +
                            "AND UserPrivileges.TableName= '" + cmd[3] + "'" +
                            "AND UserPrivileges.PrivId = 2 AND UserRoles.UserId = " + Integer.toString(current_uID);
                    rs = stmt.executeQuery(sql);
                    if (rs.next()){


                        sql = "SELECT * FROM " + cmd[3];
                        rs = stmt.executeQuery(sql);
                        ResultSetMetaData md = rs.getMetaData();
                        int rowCount = md.getColumnCount();
                        for (int j = 1; j<rowCount; j++){
                            if (j == rowCount - 1){
                                System.out.println(md.getColumnName(j));
                                fr.write(md.getColumnName(j) + "\n");
                            }
                            else {
                                System.out.print(md.getColumnName(j) + ", ");
                                fr.write(md.getColumnName(j) + ", ");
                            }
                        }
                        while(rs.next()){
                            System.out.println(rs.getInt(1)+", " +rs.getString(2)+", "+rs.getString(3)+", "+rs.getString(4));
                            fr.write(rs.getInt(1)+", " +rs.getString(2)+", "+rs.getString(3)+", "+rs.getString(4) + "\n");
                        }

                    }
                    else{
                        System.out.println("Authorization failure");
                        fr.write("Authorization failure\n");
                    }
                }

                if (cmd[0].equals("EXIT")){
                    fr.close();
                    rs.close();
                    stmt.close();
                    conn.close();
                    return;
                }
                i++;
                fr.write("\n");
            }



            //STEP 6: Clean-up environment
            rs.close();
            stmt.close();
            conn.close();
        }catch(SQLException se){
            //Handle errors for JDBC
            se.printStackTrace();
        }catch(Exception e){
            //Handle errors for Class.forName
            e.printStackTrace();
        }finally{
            //finally block used to close resources
            try{
                if(stmt!=null)
                    stmt.close();
            }catch(SQLException se2){
            }// nothing we can do
            try{
                if(conn!=null)
                    conn.close();
            }catch(SQLException se){
                se.printStackTrace();
            }//end finally try
        }//end try
    }//end main
}//end FirstExample
