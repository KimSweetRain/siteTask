<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file = "../include/sessionCheck.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.koreait.db.Dbconn" %>
<%
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	request.setCharacterEncoding("UTF-8");

	String idx=request.getParameter("idx");
	
	String userid=(String)session.getAttribute("userid");
	String username=(String)session.getAttribute("name");
	String title="";
	String date="";
	String name="";
	int hit=0;
	int like=0;
	String content="";
	String sql="";
	String b_userid="";
	String re_idx="";
	String re_name="";
	String re_userid="";
	String re_content="";
	String re_regdate="";
	
	boolean isLike = false;
	
	try{
		conn = Dbconn.getConnection();
		if(conn != null){
			sql = "select * from tb_hit where hit_userid=? and hit_boardidx=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, userid);
			pstmt.setString(2, idx);
			rs = pstmt.executeQuery();
			if(!rs.next()){
				sql = "insert into tb_hit (hit_userid, hit_boardidx) values (?, ?)";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, userid);
				pstmt.setString(2, idx);
				pstmt.executeUpdate();
				
				sql = "update tb_board set b_hit = b_hit + 1 where b_idx=?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, idx);
				pstmt.executeUpdate();
			}
			
			sql = "select * from tb_board where b_idx=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, idx);
			rs = pstmt.executeQuery();
			if(rs.next()){
				sql = "select like_idx from tb_like where like_boardidx=? and like_userid=?";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, idx);
				pstmt.setString(2, userid);
				ResultSet rs_like = pstmt.executeQuery();
				if(rs_like.next()){
					isLike = true;
				}
				
				title=rs.getString("b_title");
				date=rs.getString("b_regdate");
				name=rs.getString("b_name");
				like=rs.getInt("b_like");
				hit=rs.getInt("b_hit");
				b_userid=rs.getString("b_userid");
				content=rs.getString("b_content");
			}
			
			sql = "select * from tb_reply where re_boardidx=? order by re_idx desc";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, idx);
			rs = pstmt.executeQuery();
		}
	}catch(Exception e){
		e.printStackTrace();
	}
	
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>글보기</title>
	<script>
	function replyDel(re_idx,b_idx){
		const yn = confirm("해당 댓글을 삭제하시겠습니까?");
		if(yn) location.href="../reply_del_ok?re_idx="+re_idx+"&idx="+b_idx;
	}
	function del(idx){
		const yn = confirm("해당 글을 삭제하시겠습니까?");
		if(yn) location.href="../delete_ok?idx="+idx;
	}
	function like(){
		const isHeart= document.querySelector("img[title=on]");
		if(isHeart){
			document.getElementById('heart').setAttribute('src', './like_off.png');
			document.getElementById('heart').setAttribute('title', 'off');
		}else{
			document.getElementById('heart').setAttribute('src', './like_on.png');
			document.getElementById('heart').setAttribute('title', 'on');
		}
		const xhr = new XMLHttpRequest();
		xhr.onreadystatechange = function(){
			if(xhr.readyState == XMLHttpRequest.DONE && xhr.status == 200){
				document.getElementById("like").innerHTML = xhr.responseText;
			}
		}
		xhr.open('GET', 'like_ok.jsp?idx=<%=idx%>', true);
		xhr.send();
	}
	</script>
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
	#heart {
		width:20px;
	}
</style>
</head>
<body>
	<h2>글보기</h2>
	<table>
		<tr>
			<th>제목</th>
			<td><%=title %></td>
		</tr>
		<tr>
			<th>날짜</th>
			<td><%=date %></td>
		</tr>
		<tr>
			<th>작성자</th>
			<td><%=name %></td>
		</tr>
		<tr>
			<th>조회수</th>
			<td><%=hit %></td>
		</tr>
		<tr>
			<th>좋아요</th>
			<td id="likeN"><%if(isLike){%><img id="heart" src="./like_on.png" alt="좋아요" onclick="like()">
			<%} else{ %><img id="heart" src="./like_off.png" alt="좋아요" onclick="like()"><%} %><span id="like">&nbsp;<%=like %></span></td>
		</tr>
		<tr>
			<th>내용</th>
			<td><%=content %></td>
		</tr>
		<tr>
			<td colspan="2">
			
<%
	if(b_userid.equals(userid)){
%>
			
				<input type="button" value="수정" onclick="location.href='edit.jsp?idx=<%=idx%>'">
				<input type="button" value="삭제" onclick="del(<%=idx%>)">
<%
	}
%>
				<input type="button" value="리스트" onclick="location.href='list.jsp'">
				</a>
			</td>
		</tr>
	</table>
	<hr>
	<form method="post" action="../re_write_ok">
		<input type="hidden" name="b_idx" value="<%=idx %>">
		<p><%=userid %>(<%=username %>): <input type="text" name="re_content">
		<button>확인</button></p>
	</form>
	<hr>
<%
	while(rs.next()){
		re_name=rs.getString("re_name");
		re_content=rs.getString("re_content");
		re_regdate=rs.getString("re_regdate");
		re_idx=rs.getString("re_idx");
		re_userid=rs.getString("re_userid");
%>
		<p>🍔 <%=re_name %>: <%=re_content %> | (<%=re_regdate %>)
<%		
		if(re_userid.equals(userid)){
%>
			<input type="button" value="삭제" onclick="replyDel('<%=re_idx%>','<%=idx%>')"></p>
<%
		}
	}
%>	
</body>
</html>