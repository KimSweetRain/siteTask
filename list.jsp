<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file = "../include/sessionCheck.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="com.koreait.db.Dbconn" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	request.setCharacterEncoding("UTF-8");
	
	ResultSet postCount=null;
	int postCnt=0;
	int pagePerCount = 10; // 페이지당 글 갯수
	int start = 0; // mysql 시작 글번호

	
	String pageNum = request.getParameter("pageNum");
	if(pageNum != null && !pageNum.equals("")){
		start = (Integer.parseInt(pageNum) - 1) * pagePerCount;
	} else{
		pageNum = "1";
		start = 0;
	}
	
	try{
		conn = Dbconn.getConnection();
		if(conn != null){
			String sql = "select * from tb_board order by b_idx desc limit ?, ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, start);
			pstmt.setInt(2, pagePerCount);
			rs = pstmt.executeQuery();
			sql = "select count(b_idx) as cnt from tb_board";
			pstmt = conn.prepareStatement(sql);
			postCount = pstmt.executeQuery();
			if(postCount.next()){
				postCnt = postCount.getInt("cnt");
			}
			
			ResultSet rs_reply = pstmt.executeQuery();
		}
	}catch(Exception e){
		e.printStackTrace();
	}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>리스트</title>
<style>
	table {
		width: 800px;
		border: 1px solid black;
		border-collapse: collapse;
	}
	th, td {
		border: 1px solid black;
		padding: 10px;
	}
	#tableTitle{
		width: 220px;
	}
</style>
</head>
<body>
	<h2>리스트</h2>
	<p>[<%=postCnt %>]</p>
	<table>
		<tr>
			<th>번호</th>
			<th id="tableTitle">제목</th>
			<th>글쓴이</th>
			<th>조회수</th>
			<th>날짜</th>
			<th>좋아요</th>
		</tr>
<%
	int postIdx = postCnt + 1;
	int postNum = 0;
	while(rs.next()){
		String idx=rs.getString("b_idx");
		String title=rs.getString("b_title");
		String userid=rs.getString("b_userid");
		String name=rs.getString("b_name");
		String hit=rs.getString("b_hit");
		String date=rs.getString("b_regdate");
		String like=rs.getString("b_like");
		
		//날짜
		SimpleDateFormat transFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date today = transFormat.parse(date);        //오늘 날짜
		long now = System.currentTimeMillis();
		long inputDate = today.getTime();
		
		String sql = "select count(re_idx) as cnt from tb_reply where re_boardidx=?";
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, idx);
		ResultSet rs_reply = pstmt.executeQuery();
		
		//댓글 카운트
		String replyCnt = "";
		
		
		if(rs_reply.next()){
			int cnt = rs_reply.getInt("cnt");
			if(cnt>0){
				replyCnt = "[" + cnt + "]";
			}
			
		}
%>
		<tr>
			<td><%
			if(postNum % 10 == 0){
				if(Integer.parseInt(pageNum) != 1){
				postIdx = postIdx - ((Integer.parseInt(pageNum)-1)*10);
				};
			}
			postIdx--;
			postNum++;
			
			%><%=postIdx %></td>
			<td><b style="color:red">
			<%
				
			%>
			</b>
			<%
				if(now - inputDate < (1000 * 60 * 60 * 24 * 1)){
			%>
				<b style="color:red; font-size:18px">new &nbsp;</b>
			<%
				}
			%>
			<a href="view.jsp?idx=<%=idx %>"><%=title %><%=replyCnt %></a></td> <!-- 해당 게시글 링크로 넘어감 -->
			<td><%=userid %>(<%=name %>)</td>
			<td><%=hit %></td>
			<td><%=date %></td>
			<td><%=like %></td>
		</tr>
<%
	}
	int pageNums = 0;
	if(postCnt % pagePerCount == 0){
		pageNums = (postCnt / pagePerCount);
	} else{
		pageNums = (postCnt / pagePerCount) + 1;
	}
%>
		<tr>
			<td colspan="6">
			<%
				for(int i = 1; i<=pageNums; i++){
					out.print("<a href='list.jsp?pageNum=" + i + "'>[" + i + "]</a>&nbsp;");
				}
			%>
			</td>
		</tr>
	</table>
	<p><a href="write.jsp">글쓰기</a> | <a href="../login.jsp">돌아가기</a></p>
</body>
</html>