<%--
/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/portlet/journal/init.jsp" %>

<%
JournalFolder folder = (JournalFolder)request.getAttribute("view.jsp-folder");

long folderId = GetterUtil.getLong((String)request.getAttribute("view.jsp-folderId"));

long parentFolderId = JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID;

boolean expandFolder = ParamUtil.getBoolean(request, "expandFolder");

if (folder != null) {
	parentFolderId = folder.getParentFolderId();

	if (expandFolder) {
		parentFolderId = folderId;
	}

	if (parentFolderId != JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID) {
		try {
			JournalFolderServiceUtil.getFolder(folderId);
		}
		catch (NoSuchFolderException nsfe) {
			parentFolderId = JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID;
		}
	}
}

int entryStart = ParamUtil.getInteger(request, "entryStart");
int entryEnd = ParamUtil.getInteger(request, "entryEnd", SearchContainer.DEFAULT_DELTA);

int folderStart = ParamUtil.getInteger(request, "folderStart");
int folderEnd = ParamUtil.getInteger(request, "folderEnd", SearchContainer.DEFAULT_DELTA);

List<JournalFolder> folders = JournalFolderServiceUtil.getFolders(scopeGroupId, parentFolderId, folderStart, folderEnd);

int total = 0;

if (folderId != JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID) {
	total = JournalFolderServiceUtil.getFoldersCount(scopeGroupId, parentFolderId);
}

request.setAttribute("view_folders.jsp-total", String.valueOf(total));

String parentTitle = StringPool.BLANK;

if ((folderId != JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID) && (parentFolderId > 0)) {
	JournalFolder grandParentFolder = JournalFolderServiceUtil.getFolder(parentFolderId);

	parentTitle = grandParentFolder.getName();
}
else {
	parentTitle = LanguageUtil.get(pageContext, "home");
}
%>

<liferay-ui:app-view-navigation title="<%= parentTitle %>">
	<ul class="lfr-component">
		<c:choose>
			<c:when test="<%= ((folderId == JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID) && !expandFolder) %>">

				<%
				int foldersCount = JournalFolderServiceUtil.getFoldersCount(scopeGroupId, folderId);
				%>

				<liferay-portlet:renderURL varImpl="viewArticlesHomeURL">
					<portlet:param name="struts_action" value="/journal/view" />
					<portlet:param name="folderId" value="<%= String.valueOf(JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID) %>" />
					<portlet:param name="entryStart" value="0" />
					<portlet:param name="entryEnd" value="<%= String.valueOf(entryEnd - entryStart) %>" />
					<portlet:param name="folderStart" value="0" />
					<portlet:param name="folderEnd" value="<%= String.valueOf(folderEnd - folderStart) %>" />
				</liferay-portlet:renderURL>

				<%
				PortletURL expandArticlesHomeURL = PortletURLUtil.clone(viewArticlesHomeURL, liferayPortletResponse);

				expandArticlesHomeURL.setParameter("expandFolder", Boolean.TRUE.toString());

				String navigation = ParamUtil.getString(request, "navigation", "home");

				String structureId = ParamUtil.getString(request, "structureId");

				request.setAttribute("view_entries.jsp-folder", folder);
				request.setAttribute("view_entries.jsp-folderId", String.valueOf(folderId));

				Map<String, Object> dataExpand = new HashMap<String, Object>();

				dataExpand.put("folder-id", JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID);

				Map<String, Object> dataView = new HashMap<String, Object>();

				dataView.put("folder-id", JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID);
				dataView.put("navigation", "home");
				dataView.put("title", LanguageUtil.get(pageContext, "home"));
				%>

				<liferay-ui:app-view-navigation-entry
					actionJsp="/html/portlet/journal/folder_action.jsp"
					dataExpand="<%= dataExpand %>"
					dataView="<%= dataView %>"
					entryTitle='<%= LanguageUtil.get(pageContext, "home") %>'
					expandURL="<%= expandArticlesHomeURL.toString() %>"
					iconImage="../aui/home"
					selected='<%= (navigation.equals("home") && (folderId == JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID)) && Validator.isNull(structureId) %>'
					showExpand="<%= foldersCount > 0 %>"
					viewURL="<%= viewArticlesHomeURL.toString() %>"
				/>

				<liferay-portlet:renderURL varImpl="viewRecentArticlesURL">
					<portlet:param name="struts_action" value="/journal/view" />
					<portlet:param name="navigation" value="recent" />
					<portlet:param name="folderId" value="<%= String.valueOf(JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID) %>" />
					<portlet:param name="entryStart" value="0" />
					<portlet:param name="entryEnd" value="<%= String.valueOf(entryEnd - entryStart) %>" />
					<portlet:param name="folderStart" value="0" />
					<portlet:param name="folderEnd" value="<%= String.valueOf(folderEnd - folderStart) %>" />
				</liferay-portlet:renderURL>

				<%
				dataView = new HashMap<String, Object>();

				dataView.put("navigation", "recent");
				%>

				<liferay-ui:app-view-navigation-entry
					dataView="<%= dataView %>"
					entryTitle='<%= LanguageUtil.get(pageContext, "recent") %>'
					iconImage="../aui/clock"
					selected='<%= navigation.equals("recent") %>'
					viewURL="<%= viewRecentArticlesURL.toString() %>"
				/>

				<c:if test="<%= themeDisplay.isSignedIn() %>">
					<liferay-portlet:renderURL varImpl="viewMyArticlesURL">
						<portlet:param name="struts_action" value="/journal/view" />
						<portlet:param name="navigation" value="mine" />
						<portlet:param name="folderId" value="<%= String.valueOf(JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID) %>" />
						<portlet:param name="entryStart" value="0" />
						<portlet:param name="entryEnd" value="<%= String.valueOf(entryEnd - entryStart) %>" />
						<portlet:param name="folderStart" value="0" />
						<portlet:param name="folderEnd" value="<%= String.valueOf(folderEnd - folderStart) %>" />
					</liferay-portlet:renderURL>

					<%
					dataView = new HashMap<String, Object>();

					dataView.put("navigation", "mine");
					%>

					<liferay-ui:app-view-navigation-entry
						dataView="<%= dataView %>"
						entryTitle='<%= LanguageUtil.get(pageContext, "mine") %>'
						iconImage="../aui/person"
						selected='<%= navigation.equals("mine") %>'
						viewURL="<%= viewMyArticlesURL.toString() %>"
					/>
				</c:if>

				<%
				List<JournalStructure> structures = JournalStructureLocalServiceUtil.getStructures(scopeGroupId);
				%>

				<c:if test="<%= !structures.isEmpty() %>">
					<liferay-portlet:renderURL varImpl="viewBasicJournalStructureArticlesURL">
						<portlet:param name="struts_action" value="/journal/view" />
						<portlet:param name="folderId" value="<%= String.valueOf(JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID) %>" />
						<portlet:param name="structureId" value="0" />
						<portlet:param name="entryStart" value="0" />
						<portlet:param name="entryEnd" value="<%= String.valueOf(entryEnd - entryStart) %>" />
						<portlet:param name="folderStart" value="0" />
						<portlet:param name="folderEnd" value="<%= String.valueOf(folderEnd - folderStart) %>" />
					</liferay-portlet:renderURL>

					<%
					dataView = new HashMap<String, Object>();

					dataView.put("file-entry-type-id", 0);
					%>

					<liferay-ui:app-view-navigation-entry
						cssClassName="folder structure"
						dataView="<%= dataView %>"
						entryTitle='<%= LanguageUtil.get(pageContext, "basic-document") %>'
						iconImage="copy"
						selected='<%= (structureId == "0") %>'
						viewURL="<%= viewBasicJournalStructureArticlesURL.toString() %>"
					/>
				</c:if>

				<%
				for (JournalStructure structure : structures) {
				%>

					<liferay-portlet:renderURL varImpl="viewJournalStructureArticlesURL">
						<portlet:param name="struts_action" value="/journal/view" />
						<portlet:param name="folderId" value="<%= String.valueOf(JournalFolderConstants.DEFAULT_PARENT_FOLDER_ID) %>" />
						<portlet:param name="structureId" value="<%= structure.getStructureId() %>" />
						<portlet:param name="entryStart" value="0" />
						<portlet:param name="entryEnd" value="<%= String.valueOf(entryEnd - entryStart) %>" />
						<portlet:param name="folderStart" value="0" />
						<portlet:param name="folderEnd" value="<%= String.valueOf(folderEnd - folderStart) %>" />
					</liferay-portlet:renderURL>

					<%
					dataView = new HashMap<String, Object>();

					dataView.put("structure-id", structure.getStructureId());
					%>

					<liferay-ui:app-view-navigation-entry
						cssClassName="folder structure"
						dataView="<%= dataView %>"
						entryTitle="<%= HtmlUtil.escape(structure.getName(locale)) %>"
						iconImage="copy"
						selected="<%= structureId.equals(structure.getStructureId()) %>"
						viewURL="<%= viewJournalStructureArticlesURL.toString() %>"
					/>

				<%
				}
				%>

			</c:when>
			<c:otherwise>
				<liferay-portlet:renderURL varImpl="viewURL">
					<portlet:param name="struts_action" value="/journal/view" />
					<portlet:param name="folderId" value="<%= String.valueOf(parentFolderId) %>" />
					<portlet:param name="entryStart" value="0" />
					<portlet:param name="entryEnd" value="<%= String.valueOf(entryEnd - entryStart) %>" />
					<portlet:param name="folderStart" value="0" />
					<portlet:param name="folderEnd" value="<%= String.valueOf(folderEnd - folderStart) %>" />
				</liferay-portlet:renderURL>

				<%
				PortletURL expandViewURL = PortletURLUtil.clone(viewURL, liferayPortletResponse);

				expandViewURL.setParameter("expandFolder", Boolean.TRUE.toString());

				Map<String, Object> dataExpand = new HashMap<String, Object>();

				dataExpand.put("folder-id", parentFolderId);

				Map<String, Object> dataView = new HashMap<String, Object>();

				dataView.put("folder-id", parentFolderId);
				%>

				<liferay-ui:app-view-navigation-entry
					browseUp="<%= true %>"
					dataExpand="<%= dataExpand %>"
					dataView="<%= dataView %>"
					entryTitle='<%= LanguageUtil.get(pageContext, "up") %>'
					expandURL="<%= expandViewURL.toString() %>"
					iconSrc='<%= themeDisplay.getPathThemeImages() + "/arrows/01_up.png" %>'
					showExpand="<%= true %>"
					viewURL="<%= viewURL.toString() %>"
				/>

				<%
				for (JournalFolder curFolder : folders) {
					int foldersCount = JournalFolderServiceUtil.getFoldersCount(scopeGroupId, curFolder.getFolderId());
					int articlesCount = JournalArticleServiceUtil.getArticlesCount(scopeGroupId, curFolder.getFolderId());

					request.setAttribute("view_entries.jsp-folder", curFolder);
					request.setAttribute("view_entries.jsp-folderId", String.valueOf(curFolder.getFolderId()));
					request.setAttribute("view_entries.jsp-folderSelected", String.valueOf(folderId == curFolder.getFolderId()));
				%>

					<liferay-portlet:renderURL varImpl="viewURL">
						<portlet:param name="struts_action" value="/journal/view" />
						<portlet:param name="folderId" value="<%= String.valueOf(curFolder.getFolderId()) %>" />
						<portlet:param name="entryStart" value="0" />
						<portlet:param name="entryEnd" value="<%= String.valueOf(entryEnd - entryStart) %>" />
						<portlet:param name="folderStart" value="0" />
						<portlet:param name="folderEnd" value="<%= String.valueOf(folderEnd - folderStart) %>" />
					</liferay-portlet:renderURL>

					<%
					expandViewURL = PortletURLUtil.clone(viewURL, liferayPortletResponse);

					expandViewURL.setParameter("expandFolder", Boolean.TRUE.toString());

					dataExpand = new HashMap<String, Object>();

					dataExpand.put("folder-id", curFolder.getFolderId());

					dataView = new HashMap<String, Object>();

					dataView.put("folder-id", curFolder.getFolderId());
					dataView.put("title", curFolder.getName());
					%>

					<liferay-ui:app-view-navigation-entry
						actionJsp="/html/portlet/journal/folder_action.jsp"
						dataExpand="<%= dataExpand %>"
						dataView="<%= dataView %>"
						entryTitle="<%= curFolder.getName() %>"
						expandURL="<%= expandViewURL.toString() %>"
						iconImage='<%= (foldersCount + articlesCount) > 0 ? "folder_full_document" : "folder_empty" %>'
						selected="<%= (curFolder.getFolderId() == folderId) %>"
						showExpand="<%= foldersCount > 0 %>"
						viewURL="<%= viewURL.toString() %>"
					/>

				<%
				}
				%>

			</c:otherwise>
		</c:choose>
	</ul>

	<aui:script>
		Liferay.fire(
			'<portlet:namespace />pageLoaded',
			{
				paginator: {
					name: 'folderPaginator',
					state: {
						page: <%= folderEnd / (folderEnd - folderStart) %>,
						rowsPerPage: <%= (folderEnd - folderStart) %>,
						total: <%= total %>
					}
				}
			}
		);
	</aui:script>
</liferay-ui:app-view-navigation>