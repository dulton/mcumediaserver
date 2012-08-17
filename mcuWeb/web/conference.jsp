<%@page contentType="text/html"%>
<%@page pageEncoding="ISO-8859-1"%>
<%@page import="java.util.Iterator"%> 
<%@page import="org.murillo.mcuWeb.ConferenceMngr"%>
<%@page import="org.murillo.mcuWeb.Participant"%>
<%@page import="org.murillo.mcuWeb.Conference"%>
<%@page import="org.murillo.mcuWeb.exceptions.ConferenceNotFoundExcetpion"%>
<%
    Conference conf;
    //Get conference manager
    ConferenceMngr confMngr = (ConferenceMngr) getServletContext().getAttribute("confMngr");
    //Get the conference id
    String uid = request.getParameter("uid");

    try {
	//Get conference
	conf = confMngr.getConference(uid);
    } catch (ConferenceNotFoundExcetpion ex) {
	//Go to index
	response.sendRedirect("index.jsp");
	//Exit
	return;
    }
    //Get participant iterator
   Iterator<Participant> itPart = null;
%>
<script>
    var uid = "<%=uid%>";
    function removeParticipant(partId)
    {
        var param = {uid:uid, partId:partId};
        return callController("removeParticipant", param);
    }
    function setVideoMute(partId, flag)
    {
        var param = {uid:uid, partId:partId, flag:flag };
        return callController("setVideoMute",param);
    }
    function setAudioMute(partId, flag)
    {
        var param = {uid:uid, partId:partId, flag:flag };
        return callController("setAudioMute",param);
    }
    function changeParticipantProfile(partId,profileId)
    {
	var param = {uid:uid, partId:partId, profileId:profileId };
        return callController("changeParticipantProfile",param);
    }
    function setMosaicSlot(num, id)
    {
        var param = {uid:uid, num:num, id:id };
        return callControllerAsync("setMosaicSlot",param);
    }
</script>
<fieldset style="width:48%;float:right">
    <legend><img src="icons/application_view_tile.png"> Mosaic</legend>
     <img src="icons/mosaic<%=conf.getCompType()%>.png" style="float:right">
     <table class="form">
            <form onSumbit="return false;">
            <% 
                //Get vector with slots positions
                Integer[] slots = conf.getMosaicSlots();
               
                //Print it
                for(int i=0;i<conf.getNumSlots();i++)
                {
            %>
            <tr>
                <td>Position <%=i+1%>:</td>
                <td><select name="pos" onchange="setMosaicSlot(<%=i%>,this.value);">
                        <option value="0"  <%=slots[i].equals(0)?"selected":""%>>Free
                        <option value="-1" <%=slots[i].equals(-1)?"selected":""%>>Lock
		<%
		    //Check VAD
		    if (conf.isVAD())
		    {
		%>
			<option value="-2" <%=slots[i].equals(-1)?"selected":""%>>VAD
		<%
		    }
                    //Get iterator
                    itPart = conf.getParticipants().values().iterator();
                    //Loop 
                    while(itPart.hasNext()) 
                    {
                        // Get mixer
                        Participant part = itPart.next();
                        //Print it
                        %><option value="<%=part.getId()%>" <%=slots[i].equals(part.getId())?"selected":""%>><%=part.getName()%><%
                    }
                %>
                    </select>
                </td>     
            </tr>
            <%
                }
            %>
            </form>
        </table>
</fieldset>

<fieldset style="width:48%;">
    <legend><img src="icons/image.png"> Conference</legend>
        <table class="form">
            <form method="POST" action="controller/setCompositionType">
            <input type="hidden" name="uid" value="<%=conf.getUID()%>">
            <tr>
                <td>Name:</td>
                <td><%=conf.getName()%></td>
            </tr>
            <tr>
                <td>DID:</td>
                <td><%=conf.getDID()%></td>
            </tr>
            <tr>
                <td>Mixer:</td>
                <td><%=conf.getMixer().getName()%></td>
            </tr>
            <tr>
                <td>Composition:</td>
                <td><select name="compType" value="<%=conf.getCompType()%>">
                    <%
                        //Get mosaics
                        java.util.HashMap<Integer,String> mosaics = org.murillo.mcuWeb.MediaMixer.getMosaics();
                        //Get iterator
                        Iterator<java.lang.Integer> itMosaics = mosaics.keySet().iterator();
                        //Loop 
                        while(itMosaics.hasNext()) {
                            //Get key and value
                            Integer k = itMosaics.next();
                            String v = mosaics.get(k);
                            %><option value="<%=k%>" <%=conf.getCompType()==k?"selected":""%> ><%=v%><%
                        }
                    %>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Size</td>
                <td><select name="size" value="<%=conf.getSize()%>">
                <%
                        //Get sizes
                        java.util.HashMap<Integer,String> sizes = org.murillo.mcuWeb.MediaMixer.getSizes();
                        //Get iterator
                        Iterator<java.lang.Integer> itSizes = sizes.keySet().iterator();
                        //Loop 
                        while(itSizes.hasNext()) {
                            //Get key and value
                            Integer k = itSizes.next();
                            String v = sizes.get(k);
                            %><option value="<%=k%>" <%=conf.getSize()==k?"selected":""%> ><%=v%><%
                        }
                    %>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Default profile:</td>
                <td><select name="profileId">
                     <%
                        //Get profiles
                        Iterator<org.murillo.mcuWeb.Profile> itProf = confMngr.getProfiles().values().iterator();
                        //Loop 
                        while(itProf.hasNext()) {
                            // Get mixer
                            org.murillo.mcuWeb.Profile profile = itProf.next();
                            //If it's the selected profile
                            %><option value="<%=profile.getUID()%>" <%=profile.getUID().equals(conf.getProfile().getUID())?"selected":""%>><%=profile.getName()%><%
                        }
                    %>
		    </select>
                </td>
            </tr>
            <tr>
               <td colspan=2>
               <input class="accept" type="submit" value="Change">
               </td>
            </tr>
            </form>
        </table>
</fieldset>

<fieldset style="width:48%;">
    <legend><img src="icons/user_add.png"> Add participant</legend>
    <form method="POST" action="controller/callParticipant">
    <input type="hidden" name="uid" value="<%=uid%>">
        <table class="form">
            <tr>
                <td>Name:</td>
                <td><input type="text" name="dest" value="sip:"></td>
                <td><input class="add" type="submit" value="Invite"></td>
            </tr>
        </table>
    </form>
</fieldset>



<fieldset style="clear:both;">
    <legend><img src="icons/group.png"> Participant List</legend>
        <table class="list">
        <tr>
            <th>Name</th>
	    <th>Profile</th>
            <th>State</th>
            <th>Actions</th>
        </tr>
        <%
        //Reset iterator
        itPart = conf.getParticipants().values().iterator();
        //Loop 
        while(itPart.hasNext()) {
            // Get participant
           Participant part = itPart.next();
            //Print values
            %>
        <tr>
            <td><%=part.getName()%></td>
	    <td><select name="profileId" onChange="changeParticipantProfile('<%=part.getId()%>',this.value)"><%
                        //Get profiles
                        itProf = confMngr.getProfiles().values().iterator();
                        //Loop
                        while(itProf.hasNext()) {
                            // Get mixer
                            org.murillo.mcuWeb.Profile profile = itProf.next();
                            //If it's the selected profile
                            %><option value="<%=profile.getUID()%>" <%=profile.getUID().equals(part.getVideoProfile().getUID())?"selected":""%>><%=profile.getName()%><%
                        }
                    %></select>
	    </td>
            <td><%=part.getState()%></td>
            <td><% if (!part.getAudioMuted()) { %><a href="#" onClick="setAudioMute('<%=part.getId()%>',true);return false;"><img src="icons/sound.png"><span>Mute audio</span></a><% } else { %><a href="#" onClick="setAudioMute('<%=part.getId()%>',false);return false;"><img src="icons/sound_mute.png"><span>Enable audio</span></a><% } %><% if (!part.getVideoMuted()) { %><a href="#" onClick="setVideoMute('<%=part.getId()%>',true);return false;"><img src="icons/webcam.png"><span>Mute video</span></a><% } else { %><a href="#" onClick="setVideoMute('<%=part.getId()%>',false);return false;"><img src="icons/webcam_delete.png"><span>Enable video</span></a><% } %><a href="#" onClick="removeParticipant('<%=part.getId()%>');return false;"><img src="icons/bin_closed.png"><span>Remove from conference</span></a></td>
        </tr><%
        }
        %>
    </table>
</fieldset>
